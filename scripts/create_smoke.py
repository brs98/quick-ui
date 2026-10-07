#!/usr/bin/env python3
"""Drive the actual Quickshell app without requiring an external IPC socket."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]

# Added only to a disposable copy of shell.qml. Calls the same automation methods
# that external IPC uses; no hooks, timers, or test data enter the shipped app.
DRIVER = r'''
    property int smokePhase: 0
    property bool capturing: false
    property string initialCode: ""
    property string configuredCode: ""
    function smokeCheck(ok, message) {
        if (!ok) { console.error("CREATE_FAIL", message); Qt.quit(); }
        return ok;
    }
    function smokeCapture(name) {
        capturing = true;
        explorer.grabToImage(result => {
            if (!smokeCheck(result.saveToFile(Quickshell.env("CREATE_ARTIFACTS") + "/" + name), "capture failed")) return;
            capturing = false; smokePhase++;
        });
    }
    Timer {
        interval: 250; running: true; repeat: true
        onTriggered: {
            if (shell.capturing) return;
            if (shell.smokePhase === 0) {
                if (explorer.preview.status !== Loader.Ready) return;
                if (!shell.smokeCheck(automation.mode("create"), "open Create")) return;
                shell.initialCode = explorer.createState.code;
                if (!shell.smokeCheck(automation.createOption("radius", "large") && automation.createOption("accent", "ocean"), "set choices")) return;
                shell.configuredCode = explorer.createState.code;
                automation.createLock("radius"); automation.createShuffle();
                if (!shell.smokeCheck(explorer.createState.config.radius === "large", "shuffle preserves lock")) return;
                automation.createUndo();
                if (!shell.smokeCheck(explorer.createState.code === shell.configuredCode, "undo restores choices")) return;
                if (!shell.smokeCheck(!automation.createLoad("not-a-preset") && explorer.createState.code === shell.configuredCode && explorer.createState.error.length > 0, "invalid code preserves state")) return;
                if (!shell.smokeCheck(automation.createLoad(shell.configuredCode) && !explorer.createState.error, "valid code clears error")) return;
                automation.mode("components"); automation.mode("create");
                if (!shell.smokeCheck(explorer.createState.code === shell.configuredCode, "mode preserves preset")) return;
                console.log("CREATE_EXPORT", automation.createExport().replace(/\n/g, ""));
                console.log("CREATE_INITIAL", shell.initialCode);
                shell.smokePhase++;
            } else if (shell.smokePhase === 1) {
                shell.smokeCapture(Quickshell.env("CREATE_NARROW") === "1" ? "quickbook-create-narrow.png" : "quickbook-create-dark.png");
            } else if (shell.smokePhase === 2) {
                if (Quickshell.env("CREATE_NARROW") === "1") { console.log("CREATE_DONE"); Qt.quit(); return; }
                automation.theme(false); automation.createTheme(false); shell.smokePhase++;
            } else if (shell.smokePhase === 3) {
                shell.smokeCapture("quickbook-create-light.png");
            } else {
                console.log("CREATE_DONE"); Qt.quit();
            }
        }
    }
    Timer { interval: 12000; running: true; onTriggered: { console.error("CREATE_FAIL timeout"); Qt.quit(); } }
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native-only", action="store_true", help="render and check the app without running CLI round trips")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="quickui-create-") as directory:
        temporary = Path(directory)
        config = temporary / "app"
        config.mkdir()
        for path in ROOT.rglob("*"):
            relative = path.relative_to(ROOT)
            if path.is_file() and path.suffix in (".qml", ".js", ".svg", ".py") and not any(p.startswith(".") for p in relative.parts):
                dest = config / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, dest)
        shell = config / "shell.qml"
        source = shell.read_text()
        shell.write_text(source[:source.rfind("}")] + DRIVER + "}\n")
        runtime = temporary / "runtime"
        runtime.mkdir(mode=0o700)
        artifacts = ROOT / "artifacts"
        artifacts.mkdir(exist_ok=True)
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software", QT_SCALE_FACTOR="1",
                   QT_FORCE_STDERR_LOGGING="1", QS_NO_RELOAD_POPUP="1", XDG_RUNTIME_DIR=str(runtime), CREATE_ARTIFACTS=str(artifacts))
        for key in ("QML_IMPORT_PATH", "QML2_IMPORT_PATH", "QS_CONFIG_PATH", "QS_CONFIG_NAME", "QS_MANIFEST"):
            env.pop(key, None)
        def render(narrow=False):
            # The offscreen platform ignores resize requests after a native window
            # is shown, so exercise the narrow layout with a fresh initial size.
            if narrow:
                shell.write_text(shell.read_text().replace("implicitWidth: 1320", "implicitWidth: 640").replace("implicitHeight: 840", "implicitHeight: 700"))
            result = subprocess.run(["quickshell", "-p", str(config), "--no-color"],
                                    env=dict(env, CREATE_NARROW="1" if narrow else "0"),
                                    capture_output=True, text=True, timeout=18)
            output = result.stdout + result.stderr
            # Restricted runners can prohibit Unix socket binding. This driver
            # invokes the same methods directly and does not need that socket.
            errors = [line for line in output.splitlines() if any(token in line for token in
                      ("ERROR", "WARN scene", "TypeError:", "ReferenceError:", "Binding loop", "CREATE_FAIL"))
                      and "ERROR quickshell.ipc: Failed to start IPC server on path" not in line]
            if result.returncode or errors or "CREATE_DONE" not in output:
                raise AssertionError(output)
            return output

        output = render()
        render(narrow=True)
        for name in ("quickbook-create-dark.png", "quickbook-create-light.png", "quickbook-create-narrow.png"):
            assert (artifacts / name).stat().st_size > 1000
        exported = next(line.split("CREATE_EXPORT ", 1)[1] for line in output.splitlines() if "CREATE_EXPORT " in line)
        initial = next(line.split("CREATE_INITIAL ", 1)[1] for line in output.splitlines() if "CREATE_INITIAL " in line)
        document = json.loads(exported)
        if args.native_only:
            print("PASS: native Create mode, locked shuffle/undo, invalid codes, dark/light/narrow previews")
            return
        preset_file = temporary / "preset.json"
        preset_file.write_text(exported)

        def cli(*args):
            return subprocess.run([sys.executable, str(ROOT / "quickui"), *args], capture_output=True, text=True, check=True, timeout=10).stdout.strip()

        code = document["code"]
        assert cli("preset", "encode", str(preset_file)) == code
        cli("preset", "inspect", code, "--json")
        project = temporary / "project"
        project.mkdir()
        cli("init", "--preset", code, "--cwd", str(project))
        assert (project / "ui/PresetTheme.qml").exists()
        custom = project / "ui/Theme.qml"
        owned = custom.read_bytes() + b"\n// Owned theme customization.\n"
        custom.write_bytes(owned)
        before = {p.name: p.read_bytes() for p in (project / "ui").iterdir()}
        cli("preset", "apply", initial, "--cwd", str(project), "--dry-run")
        assert before == {p.name: p.read_bytes() for p in (project / "ui").iterdir()}
        cli("preset", "apply", initial, "--cwd", str(project))
        assert custom.read_bytes() == owned
        print("PASS: native Create mode, locked shuffle/undo, invalid codes, CLI round trip, owned theme preservation, dark/light/narrow previews")


if __name__ == "__main__":
    main()
