#!/usr/bin/env python3
"""Run the dialog example from copied sources, with an owned theme and no services."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    artifacts = ROOT / "artifacts"
    artifacts.mkdir(exist_ok=True)
    executable = shutil.which("quickshell")
    if not executable:
        raise SystemExit("Quickshell is required")
    with tempfile.TemporaryDirectory(prefix="quickui-dialogs-") as directory:
        temporary = Path(directory)
        project = temporary / "project"
        project.mkdir()
        cli = [sys.executable, str(ROOT / "quickui")]

        def install(*arguments):
            return subprocess.run(cli + list(arguments) + ["--cwd", str(project)],
                                  check=True, capture_output=True, text=True, timeout=10)

        install("init")
        theme = project / "ui/Theme.qml"
        edited = theme.read_text().replace('"#b4a0ff"', '"#6ee7c7"')
        theme.write_text(edited)
        install("add", "alert-dialog", "text-field")
        assert theme.read_text() == edited
        metadata = json.loads((project / "quickui.json").read_text())
        for name, entry in metadata["installed"].items():
            copied = project / entry["path"]
            if name != "theme":
                assert copied.read_bytes() == (ROOT / "registry/quickui" / copied.name).read_bytes()
        shutil.copy2(ROOT / "templates/dialogs.qml", project / "shell.qml")
        runtime = temporary / "runtime"
        runtime.mkdir(mode=0o700)
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software",
                   QT_FORCE_STDERR_LOGGING="1", QS_NO_RELOAD_POPUP="1", QT_SCALE_FACTOR="1",
                   XDG_RUNTIME_DIR=str(runtime))
        for key in ("QML_IMPORT_PATH", "QML2_IMPORT_PATH", "QS_CONFIG_PATH", "QS_CONFIG_NAME", "QS_MANIFEST"):
            env.pop(key, None)
        log_path = temporary / "runtime.log"
        with log_path.open("w+") as log:
            process = subprocess.Popen([executable, "-p", str(project), "--no-color"], cwd=project,
                                       env=env, stdout=log, stderr=subprocess.STDOUT)
            try:
                def ipc(*arguments):
                    return subprocess.run([executable, "ipc", "-p", str(project), "--any-display",
                                           "call", "quickui-dialogs", *arguments], env=env, text=True,
                                          capture_output=True, check=True, timeout=5).stdout.strip()

                def status():
                    return json.loads(ipc("status"))

                def eventually(check, description):
                    deadline = time.monotonic() + 10
                    while time.monotonic() < deadline:
                        if process.poll() is not None:
                            raise AssertionError("Quickshell exited")
                        try:
                            if check():
                                return
                        except (subprocess.CalledProcessError, json.JSONDecodeError):
                            pass
                        time.sleep(0.05)
                    raise AssertionError("Timed out: " + description)

                eventually(lambda: status()["name"] == "Personal workspace", "dialog composition")
                assert status()["accent"] == "#6ee7c7"
                ipc("openEditor")
                eventually(lambda: status()["editor"], "open editor")
                ipc("saveName", "Work workspace")
                eventually(lambda: not status()["editor"] and status()["name"] == "Work workspace", "save editor")
                ipc("openAlert")
                eventually(lambda: status()["alert"] and status()["cancelFocused"], "open confirmation")
                ipc("cancel")
                eventually(lambda: not status()["alert"] and status()["action"] == "Workspace kept", "cancel confirmation")
                ipc("openAlert")
                eventually(lambda: status()["alert"] and status()["cancelFocused"], "reopen confirmation")
                ipc("confirm")
                eventually(lambda: not status()["alert"] and status()["action"] == "Removal requested", "confirm action")
                for dark in (True, False):
                    ipc("theme", str(dark).lower())
                    ipc("openAlert")
                    eventually(lambda: status()["alert"] and status()["cancelFocused"] and status()["dark"] == dark, "theme and popup")
                    path = artifacts / ("quickui-dialog-dark.png" if dark else "quickui-dialog-light.png")
                    path.unlink(missing_ok=True)
                    time.sleep(0.1)
                    assert ipc("capture", str(path)) == "true"
                    eventually(lambda: path.exists() and path.stat().st_size > 1000, "dialog screenshot")
                    ipc("cancel")
                    eventually(lambda: not status()["alert"], "close confirmation")
                log.flush()
                errors = [line for line in log_path.read_text().splitlines() if any(token in line for token in
                          ("ERROR", "WARN scene", "TypeError:", "ReferenceError:", "Binding loop"))]
                assert not errors, "\n".join(errors)
                assert theme.read_text() == edited
                print("PASS: copied dialog sources, customized theme, editor save, confirm/cancel, dark/light captures")
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
