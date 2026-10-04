#!/usr/bin/env python3
"""Install into a clean project, customize its theme, and render native QML."""
import argparse
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=ROOT / "artifacts",
                        help="screenshot directory (default: repository artifacts/)")
    args = parser.parse_args()
    executable = shutil.which("qs") or shutil.which("quickshell")
    if not executable:
        raise SystemExit("Quickshell is required (tested with 0.3.1)")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    screenshot = args.output_dir.resolve() / "quickui-starter.png"

    with tempfile.TemporaryDirectory(prefix="quickui-installed-") as directory:
        temporary = Path(directory)
        project = temporary / "project"
        project.mkdir()
        command = [sys.executable, str(ROOT / "quickui")]

        def install(*arguments):
            return subprocess.run(command + list(arguments) + ["--cwd", str(project)],
                                  text=True, capture_output=True, check=True, timeout=10)

        install("init")
        theme = project / "ui/Theme.qml"
        original = theme.read_text()
        assert '"#b4a0ff"' in original, "Update smoke's theme customization for the new default"
        edited = original.replace('"#b4a0ff"', '"#6ee7c7"').encode()
        theme.write_bytes(edited)
        entries = json.loads((ROOT / "registry.json").read_text())["components"]
        component_names = ["button", "icon-button", "text-field", "switch", "checkbox",
                           "slider", "select", "card", "badge", "separator"]
        result = install("add", *component_names)
        assert "Kept customized dependency ui/Theme.qml" in result.stdout
        assert theme.read_bytes() == edited, "Installer changed the owned theme"
        for name in component_names:
            filename = entries[name]["file"]
            assert (project / "ui" / filename).read_bytes() == (ROOT / "registry/quickui" / filename).read_bytes()
        shutil.copyfile(ROOT / "templates/starter.qml", project / "shell.qml")
        # Only copied project sources are on the QML import path.
        assert not any(path.is_symlink() for path in project.rglob("*"))
        runtime = temporary / "runtime"
        runtime.mkdir(mode=0o700)
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software",
                   QT_FORCE_STDERR_LOGGING="1", QS_NO_RELOAD_POPUP="1",
                   QT_SCALE_FACTOR="1", XDG_RUNTIME_DIR=str(runtime))
        for key in ("QML_IMPORT_PATH", "QML2_IMPORT_PATH", "QS_CONFIG_PATH", "QS_CONFIG_NAME", "QS_MANIFEST"):
            env.pop(key, None)
        ipc_command = [executable, "ipc", "-p", str(project), "--any-display", "call", "quickui-starter"]
        log_path = temporary / "runtime.log"
        with log_path.open("w+") as log:
            process = subprocess.Popen([executable, "-p", str(project), "--no-color"], cwd=project,
                                       env=env, stdout=log, stderr=subprocess.STDOUT)
            try:
                def ipc(*arguments):
                    return subprocess.run(ipc_command + list(arguments), env=env, text=True,
                                          capture_output=True, timeout=5, check=True).stdout.strip()

                def status():
                    return json.loads(ipc("status"))

                def eventually(predicate, description):
                    deadline = time.monotonic() + 10
                    while time.monotonic() < deadline:
                        if process.poll() is not None:
                            raise AssertionError("Quickshell exited unexpectedly")
                        try:
                            if predicate():
                                return
                        except (subprocess.CalledProcessError, json.JSONDecodeError):
                            pass
                        time.sleep(0.1)
                    raise AssertionError("Timed out: " + description)

                eventually(lambda: status()["width"] == 720, "starter scene")
                initial = status()
                assert initial["height"] == 700
                assert initial["dark"] is True
                assert initial["accent"] == "#6ee7c7", "Installed theme edit did not reach the scene"
                assert initial["buttonAccent"] == initial["accent"]
                assert initial["volume"] == 64 and initial["notifications"] is True
                assert initial["output"] == "Studio speakers"
                ipc("theme", "false")
                eventually(lambda: status()["dark"] is False and status()["accent"] == "#7152cf", "light theme")
                ipc("cycleAccent")
                eventually(lambda: status()["buttonAccent"] == "#92501a", "light amber accent")
                ipc("theme", "true")
                eventually(lambda: status()["buttonAccent"] == "#f2b880", "dark amber accent")
                ipc("cycleAccent")
                eventually(lambda: status()["buttonAccent"] == "#b4a0ff", "dark lavender accent")
                ipc("theme", "false")
                eventually(lambda: status()["buttonAccent"] == "#7152cf", "light lavender accent")
                ipc("apply")
                eventually(lambda: status()["message"] == "Saved preferences for Creative space (mock)", "mock action")
                ipc("theme", "true")
                ipc("accent", "#6ee7c7")
                time.sleep(0.25)
                screenshot.unlink(missing_ok=True)
                assert ipc("capture", str(screenshot)) == "true"
                eventually(lambda: screenshot.exists() and screenshot.stat().st_size > 1000, "native PNG capture")
                header = screenshot.read_bytes()[:24]
                assert header[:8] == b"\x89PNG\r\n\x1a\n"
                assert struct.unpack(">II", header[16:24]) == (720, 700)
                log.flush()
                errors = [line for line in log_path.read_text().splitlines() if any(token in line for token in
                          ("ERROR", "WARN scene", "TypeError:", "ReferenceError:", "Binding loop"))]
                assert not errors, "\n".join(errors)
                assert theme.read_bytes() == edited
                print("PASS: clean source install, customized dependency, ten primitives, themes, mock action, native PNG")
                print("Screenshot:", screenshot)
            except Exception:
                log.flush()
                print(log_path.read_text(), file=sys.stderr)
                raise
            finally:
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()


if __name__ == "__main__":
    main()
