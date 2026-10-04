#!/usr/bin/env python3
"""Exercise the real Quickshell process and export two native screenshots."""
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    if not shutil.which("quickshell"):
        raise SystemExit("quickshell is required (tested with 0.3.1)")
    artifacts = ROOT / "artifacts"
    artifacts.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="quickbook-smoke-") as directory:
        temp = Path(directory)
        config = temp / "config"
        config.mkdir()
        # Test reload in a disposable config, isolated from any running explorer.
        for source in ROOT.rglob("*.qml"):
            if any(part.startswith(".") for part in source.relative_to(ROOT).parts):
                continue
            destination = config / source.relative_to(ROOT)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)
        runtime = temp / "runtime"
        runtime.mkdir(mode=0o700)
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software",
                   QT_FORCE_STDERR_LOGGING="1", QS_NO_RELOAD_POPUP="1",
                   XDG_RUNTIME_DIR=str(runtime))
        command = ["quickshell", "ipc", "-p", str(config), "--any-display", "call", "quickbook"]
        log_path = temp / "runtime.log"
        with log_path.open("w+") as log:
            process = subprocess.Popen(["quickshell", "-p", str(config), "--no-color"],
                                       env=env, stdout=log, stderr=subprocess.STDOUT)
            try:
                def ipc(*args):
                    result = subprocess.run(command + list(args), env=env, text=True,
                                            capture_output=True, timeout=5, check=True)
                    return result.stdout.strip()

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

                def status():
                    return json.loads(ipc("status"))

                eventually(lambda: status()["loaded"], "initial story")
                initial = status()
                assert initial["story"] == "ui-button"
                assert initial["args"]["text"] == "Save changes"
                assert ipc("select", "does-not-exist") == "false"
                assert status()["story"] == initial["story"]
                assert ipc("control", "text", "not-json") == "false"
                assert ipc("control", "text", json.dumps("From IPC")) == "true"
                assert status()["args"]["text"] == "From IPC"
                ipc("reset")
                assert status()["args"] == initial["args"]
                assert ipc("select", "volume-card") == "true"
                assert ipc("control", "volume", "250") == "true"
                assert status()["args"]["volume"] == 100
                assert ipc("control", "volume", '"loud"') == "false"
                assert ipc("preset", "-1") == "false"
                ipc("preset", "0")

                def capture(filename):
                    path = artifacts / filename
                    path.unlink(missing_ok=True)
                    assert ipc("capture", str(path)) == "true"
                    eventually(lambda: path.exists() and path.stat().st_size > 1000, filename)
                    header = path.read_bytes()[:24]
                    assert header[:8] == b"\x89PNG\r\n\x1a\n"
                    assert struct.unpack(">II", header[16:24]) == (1320, 840)

                # Let Qt render the property changes before requesting a capture.
                time.sleep(0.2)
                capture("quickbook-dark.png")
                ipc("theme", "false")
                ipc("select", "notification-card")
                eventually(lambda: status()["loaded"] and not status()["dark"], "light story")
                time.sleep(0.2)
                capture("quickbook-light.png")
                with (config / "shell.qml").open("a") as shell:
                    shell.write("\n// Trigger smoke-test hot reload.\n")
                eventually(lambda: status()["story"] == "ui-button" and status()["loaded"], "hot reload")
                assert status()["args"] == initial["args"]
                log.flush()
                content = log_path.read_text()
                errors = [line for line in content.splitlines() if any(
                    token in line for token in ("ERROR", "WARN scene", "TypeError:", "ReferenceError:"))]
                assert not errors, "\n".join(errors)
                print("PASS: Quickshell startup, IPC controls, validation, theme, screenshots, and hot reload")
                print("Screenshots:", artifacts)
            except Exception:
                log.flush()
                print(log_path.read_text())
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
