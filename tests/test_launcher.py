"""Exercise launch environment selection without starting Qt or a compositor."""

import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="quickbook-launcher-")
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.runtime = self.directory / "runtime"
        self.runtime.mkdir()
        executable = self.directory / "quickshell"
        executable.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, sys\n"
            "print(json.dumps({'args': sys.argv[1:], 'env': {key: os.getenv(key) "
            "for key in ['WAYLAND_DISPLAY', 'DISPLAY', 'QT_QPA_PLATFORM', "
            "'XDG_RUNTIME_DIR', 'QS_NO_RELOAD_POPUP']}}))\n"
        )
        executable.chmod(0o755)
        self.env = os.environ.copy()
        for key in ("DISPLAY", "WAYLAND_DISPLAY", "QT_QPA_PLATFORM"):
            self.env.pop(key, None)
        self.env.update(PATH=f"{self.directory}:{os.environ['PATH']}",
                        XDG_RUNTIME_DIR=str(self.runtime))

    def bind_socket(self, name):
        endpoint = socket.socket(socket.AF_UNIX)
        endpoint.bind(str(self.runtime / name))
        self.addCleanup(endpoint.close)

    def launch(self, *args):
        return subprocess.run([str(ROOT / "quickbook"), *args], env=self.env,
                              capture_output=True, text=True, timeout=5)

    def test_discovers_single_owned_wayland_socket(self):
        self.bind_socket("wayland-1")
        result = self.launch("--no-color")
        self.assertEqual(result.returncode, 0, result.stderr)
        launched = json.loads(result.stdout)
        self.assertEqual(launched["env"]["WAYLAND_DISPLAY"], "wayland-1")
        self.assertEqual(launched["env"]["XDG_RUNTIME_DIR"], str(self.runtime))
        self.assertEqual(launched["env"]["QS_NO_RELOAD_POPUP"], "1")
        self.assertEqual(launched["args"], ["-p", str(ROOT / "shell.qml"), "--no-color"])

    def test_missing_socket_reports_how_to_launch_without_starting_qt(self):
        result = self.launch()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertIn("WAYLAND_DISPLAY", result.stderr)
        self.assertIn("desktop", result.stderr)

    def test_non_graphical_commands_do_not_need_a_display(self):
        for args in [("--help",), ("-h",), ("--version",), ("-V",),
                     ("ipc", "call", "quickbook", "status"), ("list",),
                     ("kill",), ("log",), ("msg",), ("--no-color", "list")]:
            with self.subTest(args=args):
                result = self.launch(*args)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(json.loads(result.stdout)["env"]["WAYLAND_DISPLAY"], None)

    def test_multiple_sockets_require_explicit_display(self):
        self.bind_socket("wayland-0")
        self.bind_socket("wayland-1")
        result = self.launch()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertIn("WAYLAND_DISPLAY", result.stderr)

    def test_explicit_display_and_platform_settings_are_preserved(self):
        self.bind_socket("wayland-0")
        self.bind_socket("wayland-1")
        for key, value in [("WAYLAND_DISPLAY", "wayland-custom"),
                           ("DISPLAY", ":42"), ("QT_QPA_PLATFORM", "offscreen")]:
            with self.subTest(key=key):
                self.env[key] = value
                result = self.launch()
                del self.env[key]
                self.assertEqual(result.returncode, 0, result.stderr)
                actual = json.loads(result.stdout)["env"]
                self.assertEqual(actual[key], value)
                if key != "WAYLAND_DISPLAY":
                    self.assertIsNone(actual["WAYLAND_DISPLAY"])

    def test_lock_files_and_unrelated_sockets_are_ignored(self):
        self.bind_socket("wayland-2")
        self.bind_socket("some-service")
        (self.runtime / "wayland-0").write_text("not a socket")
        (self.runtime / "wayland-2.lock").write_text("123")
        result = self.launch()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["env"]["WAYLAND_DISPLAY"], "wayland-2")

    def test_option_values_are_not_mistaken_for_commands(self):
        result = self.launch("--log-rules", "list")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
