#!/usr/bin/env python3
"""Run the menu example from copied sources, with an owned theme and no services."""
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
    with tempfile.TemporaryDirectory(prefix="quickui-menu-") as directory:
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
        install("add", "menu", "button")
        assert theme.read_text() == edited
        metadata = json.loads((project / "quickui.json").read_text())
        for name, entry in metadata["installed"].items():
            copied = project / entry["path"]
            if name != "theme":
                assert copied.read_bytes() == (ROOT / "registry/quickui" / copied.name).read_bytes()
        shutil.copy2(ROOT / "templates/menu.qml", project / "shell.qml")
        runtime = temporary / "runtime"
        runtime.mkdir(mode=0o700)
        env = dict(os.environ, QUICKBOOK_NO_PERSIST="1", QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software",
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
                                           "call", "quickui-menu", *arguments], env=env, text=True,
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

                eventually(lambda: status()["count"] == 5, "menu composition")
                assert status()["accent"] == "#6ee7c7"
                assert status()["checked"] is True
                ipc("open")
                eventually(lambda: status()["opened"], "open menu")
                ipc("toggleStatus")
                eventually(lambda: not status()["checked"] and not status()["opened"], "native toggle and dismissal")
                ipc("open")
                eventually(lambda: status()["opened"], "reopen menu")
                ipc("activateFirst")
                eventually(lambda: status()["action"] == "New workspace requested" and not status()["opened"], "native action and dismissal")
                for dark in (True, False):
                    ipc("theme", str(dark).lower())
                    ipc("open")
                    eventually(lambda: status()["opened"] and status()["dark"] == dark, "theme and popup")
                    path = artifacts / ("quickui-menu-dark.png" if dark else "quickui-menu-light.png")
                    path.unlink(missing_ok=True)
                    time.sleep(0.1)
                    assert ipc("capture", str(path)) == "true"
                    eventually(lambda: path.exists() and path.stat().st_size > 1000, "menu screenshot")
                    ipc("close")
                    eventually(lambda: not status()["opened"], "close menu")
                log.flush()
                errors = [line for line in log_path.read_text().splitlines() if any(token in line for token in
                          ("ERROR", "WARN scene", "TypeError:", "ReferenceError:", "Binding loop"))]
                assert not errors, "\n".join(errors)
                assert theme.read_text() == edited
                print("PASS: copied menu sources, customized theme, native activation/check state/dismissal, dark/light captures")
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
