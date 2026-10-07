#!/usr/bin/env python3
"""Render Quickbook with synthetic live Omarchy themes; never alters the desktop."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
DRIVER = r'''
    property int phase: 0
    property bool capturing: false
    property string originalCode: ""
    function check(ok, message) {
        if (!ok) { console.error("OMARCHY_FAIL", message); Qt.quit(); }
        return ok;
    }
    function capture(name) {
        capturing = true;
        explorer.grabToImage(result => {
            if (!shell.check(result.saveToFile(Quickshell.env("TEST_ARTIFACTS") + "/" + name), "capture")) return;
            capturing = false; phase++;
        });
    }
    Process {
        id: replaceTheme
        command: ["python3", Quickshell.env("TEST_REPLACE")]
        onExited: exitCode => { if (shell.check(exitCode === 0, "fixture replacement")) shell.phase++; }
    }
    Timer {
        interval: 300; running: true; repeat: true
        onTriggered: {
            if (shell.capturing) return;
            const builder = explorer.presetBuilder;
            if (shell.phase === 0) {
                automation.mode("create");
                shell.originalCode = builder.createState.code;
                automation.omarchyPreview(true);
                shell.phase++;
            } else if (shell.phase === 1) {
                if (!omarchySource.available) return;
                if (!shell.check(builder.effectiveTheme.accent.toString() === "#80bfff", "initial live accent")) return;
                if (!shell.check(builder.effectiveTheme.fontSize === 18, "theme font")) return;
                shell.capture("quickbook-omarchy-dark.png");
            } else if (shell.phase === 2) {
                shell.phase++; replaceTheme.running = true;
            } else if (shell.phase === 3) {
                return;
            } else if (shell.phase === 4) {
                if (!omarchySource.available || builder.effectiveTheme.accent.toString() !== "#00689e") return;
                if (!shell.check(builder.effectiveTheme.fontSize === 22, "user font override refreshed")) return;
                if (!shell.check(builder.effectiveTheme.dark === false && builder.effectiveTheme.radius === 0, "light square theme")) return;
                if (!shell.check(builder.createState.code === shell.originalCode, "q1 preserved")) return;
                builder.followSpacing = false;
                builder.radiusMultiplier = 0.75;
                builder.createState.setOption("density", "compact");
                builder.createState.setOption("motion", "none");
                if (!shell.check(builder.effectiveTheme.controlHeight === builder.generatedTheme.controlHeight && builder.effectiveTheme.motionDuration === 0, "explicit overrides")) return;
                console.log("OMARCHY_RECIPE", builder.exportRecipe().replace(/\n/g, ""));
                shell.phase++;
            } else if (shell.phase === 5) {
                shell.capture("quickbook-omarchy-light.png");
            } else {
                automation.mode("components");
                if (!shell.check(!omarchySource.enabled && !omarchySource.available, "reader disabled outside preview")) return;
                console.log("OMARCHY_DONE"); Qt.quit();
            }
        }
    }
    Timer { interval: 18000; running: true; onTriggered: { console.error("OMARCHY_FAIL timeout", omarchySource.error); Qt.quit(); } }
'''


def main():
    with tempfile.TemporaryDirectory(prefix="quickui-omarchy-") as directory:
        temporary = Path(directory)
        app = temporary / "app"
        shutil.copytree(ROOT, app, ignore=shutil.ignore_patterns(".git", "artifacts", "__pycache__"))
        current = temporary / "current"
        theme = current / "theme"
        theme.mkdir(parents=True)
        (current / "theme.name").write_text("Fixture dark")
        (theme / "colors.toml").write_text('background="#14151c"\nforeground="#eeedf5"\naccent="#80bfff"\nred="#f08095"\n')
        (theme / "shell.toml").write_text('[font]\nbase-size=18\n')
        user_shell = temporary / "user-shell.toml"
        user_shell.write_text("")
        update = temporary / "replace.py"
        update.write_text('''from pathlib import Path
import shutil
current=Path(%r)
next_theme=current/'next-theme'
next_theme.mkdir()
(next_theme/'colors.toml').write_text('background="#f4f3f8"\\nforeground="#242334"\\naccent="#00689e"\\nred="#ba2948"\\n')
(next_theme/'shell.toml').write_text('[font]\\nbase-size=16\\n')
(current/'theme').rename(current/'previous')
next_theme.rename(current/'theme')
Path(%r).write_text('[font]\\nbase-size=22\\n')
(current/'theme.name').write_text('Fixture light')
''' % (str(current), str(user_shell)))
        shell_file = app / "shell.qml"
        source = shell_file.read_text().replace('id: omarchySource', 'id: omarchySource\n        themeDirectory: ' + json.dumps(str(theme)) + '\n        userShellPath: ' + json.dumps(str(user_shell)) + '\n        querySystem: false\n        refreshInterval: 250')
        source = source.replace('implicitHeight: 840', 'implicitHeight: 1100')
        shell_file.write_text(source[:source.rfind('}')] + DRIVER + '}\n')
        runtime = temporary / "runtime"
        runtime.mkdir(mode=0o700)
        artifacts = ROOT / "artifacts"
        artifacts.mkdir(exist_ok=True)
        env = dict(os.environ, XDG_RUNTIME_DIR=str(runtime), QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software", QT_SCALE_FACTOR="1",
                   QT_FORCE_STDERR_LOGGING="1", QS_NO_RELOAD_POPUP="1", TEST_ARTIFACTS=str(artifacts), TEST_REPLACE=str(update))
        for key in ("QML_IMPORT_PATH", "QML2_IMPORT_PATH", "QS_CONFIG_PATH", "QS_CONFIG_NAME", "QS_MANIFEST"):
            env.pop(key, None)
        result = subprocess.run(["quickshell", "-p", str(app), "--no-color"], env=env, capture_output=True, text=True, timeout=24)
        output = result.stdout + result.stderr
        errors = [line for line in output.splitlines() if any(token in line for token in
                  ("ERROR", "WARN scene", "TypeError:", "ReferenceError:", "Binding loop", "OMARCHY_FAIL"))
                  and "ERROR quickshell.ipc: Failed to start IPC server on path" not in line]
        if result.returncode or errors or "OMARCHY_DONE" not in output:
            raise AssertionError(output)
        recipe = json.loads(next(line.split("OMARCHY_RECIPE ", 1)[1] for line in output.splitlines() if "OMARCHY_RECIPE " in line))
        recipe_file = temporary / "recipe.json"
        recipe_file.write_text(json.dumps(recipe))
        project = temporary / "project"
        project.mkdir()
        def cli(*args):
            return subprocess.run([sys.executable, str(ROOT / "quickui"), *args, "--cwd", str(project)], check=True, capture_output=True, text=True)
        cli("init")
        cli("omarchy", "install", "--recipe", str(recipe_file))
        generated = (project / "ui/OmarchyPreset.qml").read_text()
        assert 'followSpacing: false' in generated and 'radiusMultiplier: 0.75' in generated
        for name in ("quickbook-omarchy-dark.png", "quickbook-omarchy-light.png"):
            assert (artifacts / name).stat().st_size > 1000
        print("PASS: native Omarchy preview, live directory replacement, user typography overrides, portable code stability, recipe installation, reader lifecycle")


if __name__ == "__main__":
    main()
