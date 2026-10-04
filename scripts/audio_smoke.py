#!/usr/bin/env python3
"""Install audio-mixer into a clean project and exercise its mock adapter natively."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=ROOT / "artifacts")
    args = parser.parse_args()
    executable = shutil.which("qs") or shutil.which("quickshell")
    if not executable:
        raise SystemExit("Quickshell is required")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    destination = args.output_dir.resolve()
    entries = json.loads((ROOT / "registry.json").read_text())["components"]
    closure = set()

    def dependencies(name):
        if name in closure:
            return
        closure.add(name)
        for dependency in entries[name]["dependencies"]:
            dependencies(dependency)

    dependencies("audio-mixer")
    with tempfile.TemporaryDirectory(prefix="quickui-audio-") as directory:
        temporary = Path(directory)
        project = temporary / "project"
        project.mkdir()

        def install(*arguments):
            return subprocess.run([sys.executable, str(ROOT / "quickui"), *arguments,
                                   "--cwd", str(project)], text=True, capture_output=True,
                                  check=True, timeout=10)

        install("init")
        theme = project / "ui/Theme.qml"
        original = theme.read_text()
        assert '"#b4a0ff"' in original
        edited_theme = original.replace('"#b4a0ff"', '"#6ee7c7"').encode()
        theme.write_bytes(edited_theme)
        added = install("add", "audio-mixer")
        assert "Kept customized dependency ui/Theme.qml" in added.stdout
        assert theme.read_bytes() == edited_theme
        forbidden = re.compile(r"^\s*import\s+(?:Omarchy\b|Quickshell\b|qs\.)", re.MULTILINE)
        expected_files = set()
        for name in closure:
            filename = entries[name]["file"]
            expected_files.add(filename)
            installed = project / "ui" / filename
            canonical = ROOT / "registry/quickui" / filename
            assert installed.read_bytes() == (edited_theme if name == "theme" else canonical.read_bytes()), filename
            assert not forbidden.search(installed.read_text()), f"Service dependency in {filename}"
        assert {file.name for file in (project / "ui").iterdir()} == expected_files
        assert not any(file.is_symlink() for file in project.rglob("*"))
        shutil.copyfile(ROOT / "templates/audio.qml", project / "shell.qml")
        runtime = temporary / "runtime"
        runtime.mkdir(mode=0o700)
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software",
                   QT_FORCE_STDERR_LOGGING="1", QS_NO_RELOAD_POPUP="1", QT_SCALE_FACTOR="1",
                   XDG_RUNTIME_DIR=str(runtime))
        for key in ("QML_IMPORT_PATH", "QML2_IMPORT_PATH", "QS_CONFIG_PATH", "QS_CONFIG_NAME", "QS_MANIFEST"):
            env.pop(key, None)
        ipc_command = [executable, "ipc", "-p", str(project), "--any-display", "call", "quickui-audio-demo"]
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

                def request(action, identity="unused", value=0):
                    assert ipc("request", action, identity, str(value)) == "true", action

                def capture(name):
                    screenshot = destination / name
                    screenshot.unlink(missing_ok=True)
                    time.sleep(0.15)
                    assert ipc("capture", str(screenshot)) == "true"
                    eventually(lambda: screenshot.exists() and screenshot.stat().st_size > 1000, name)
                    header = screenshot.read_bytes()[:24]
                    assert header[:8] == b"\x89PNG\r\n\x1a\n"
                    assert struct.unpack(">II", header[16:24]) == (460, 720)
                    return screenshot

                eventually(lambda: status()["width"] == 460, "audio scene")
                initial = status()
                assert initial["height"] == 720 and initial["dark"] is True
                assert initial["accent"] == "#6ee7c7"
                assert initial["currentOutput"] == "speakers" and initial["currentInput"] == "microphone"
                assert len(initial["streams"]) == 2
                dark_capture = capture("quickui-audio-dark.png")
                ipc("theme", "false")
                eventually(lambda: status()["dark"] is False and status()["accent"] == "#7152cf", "light theme")
                light_capture = capture("quickui-audio-light.png")
                assert dark_capture.read_bytes() != light_capture.read_bytes()
                request("output-volume", value=0.35)
                request("input-volume", value=0.61)
                state = status()
                assert state["outputVolume"] == 0.35 and state["inputVolume"] == 0.61
                request("output-mute")
                request("input-mute")
                assert status()["outputMuted"] and status()["inputMuted"]
                request("all-mute")
                assert not status()["outputMuted"] and not status()["inputMuted"]
                request("all-mute")
                assert status()["outputMuted"] and status()["inputMuted"]
                request("output-select", "headphones")
                request("input-select", "webcam")
                state = status()
                assert state["currentOutput"] == "headphones" and state["currentInput"] == "webcam"
                assert sum(device["current"] for device in state["outputs"]) == 1
                assert sum(device["current"] for device in state["inputs"]) == 1
                request("stream-volume", "music", 1.2)
                request("stream-mute", "music")
                state = status()
                assert state["streams"][0]["volume"] == 1.2 and state["streams"][0]["muted"]
                assert state["streams"][1] == initial["streams"][1], "Updating a stream changed another row"
                request("stream-mute", "missing")
                assert status()["streams"] == state["streams"], "Missing stream changed the model"
                request("panel-switch", value=-1)
                assert status()["lastPanelDirection"] == -1
                request("close")
                assert status()["dismissed"] is True
                assert ipc("request", "unknown", "unused", "0") == "false"
                assert theme.read_bytes() == edited_theme
                log.flush()
                # Qt offscreen cannot apply window masks; reproduced with an empty
                # FloatingWindow. Keep every other warning (including QML) fatal.
                platform_notice = "WARN: This plugin does not support setting window masks"
                errors = [line for line in log_path.read_text().splitlines()
                          if line.strip() != platform_notice
                          and re.search(r"\b(?:WARN|ERROR)\b|TypeError:|ReferenceError:|Binding loop", line)]
                assert not errors, "\n".join(errors)
                print(f"PASS: clean audio-mixer install ({len(closure)} sources), preserved theme, exact bytes, "
                      "native dark/light rendering, component request wiring, device/stream updates, dismissal")
                print("Screenshots:", dark_capture, light_capture)
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
