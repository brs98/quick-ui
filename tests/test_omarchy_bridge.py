"""Read-only Omarchy bridge: parsing, source replacement and native polling."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
INTEGRATION = ROOT / "integrations/omarchy-theme"
spec = importlib.util.spec_from_file_location("read_theme", INTEGRATION / "read_theme.py")
bridge = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)
PALETTE = 'background = "#101020"\nforeground = "#eeeeff"\naccent = "#8899ff"\nred = "#ff0000"\n'


class BridgeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.theme = self.root / "theme"
        self.theme.mkdir()
        self.user = self.root / "user.toml"
        (self.theme / "colors.toml").write_text(PALETTE)

    def read(self):
        return bridge.snapshot(self.theme, self.user, system=False)

    def test_foundation_fallback_and_defaults(self):
        (self.theme / "colors.toml").write_text('color0="#101010"\ncolor7="#eeeeee"\ncolor4="#4466ff"\ncolor8="#888888"')
        result = self.read()
        self.assertEqual(result["colors"]["accent"], "#4466ff")
        self.assertEqual(result["colors"]["muted"], "#888888")
        self.assertEqual(result["style"]["controlHeight"], 28)
        self.assertEqual(result["style"]["fontFamily"], "monospace")

    def test_explicit_accent_wins_and_user_overrides_layer(self):
        (self.theme / "shell.toml").write_text('[font]\nbase-size=18\n[spacing]\nscale=1.5\ncontrol-gap=7\n[controls]\nselected-color="accent"\nselected-fill-alpha=0.5\n')
        self.user.write_text('[font]\nbody=21\n[spacing]\ncontrol-height=42\n')
        result = self.read()
        self.assertEqual(result["style"]["fontSize"], 21)
        self.assertEqual(result["style"]["fontScale"], 1.5)
        self.assertEqual(result["style"]["spacing"], 7)
        self.assertEqual(result["style"]["padding"], 23)
        self.assertEqual(result["style"]["controlHeight"], 42)
        self.assertEqual(result["colors"]["selection"], "#808899ff")
        self.user.unlink()
        self.assertEqual(self.read()["style"]["fontSize"], 18)

    def test_extended_toml_roles_gradients_and_alpha(self):
        (self.theme / "shell.toml").write_text('[popups]\nborder="hyprland.active-border"\nborder-alpha=0.25\nbackground=background\n[hyprland]\nactive-border="rgba(123456aa) rgba(eeeeeeff) 45deg"\n[controls]\nfocus-color=inherit\nhover-cursor-color=accent\nnormal-border-width=1 2\n[spacing]\nscale-with-font=false\n[font]\nbase-size=24\n')
        result = self.read()
        self.assertEqual(result["colors"]["border"], "#40123456")
        self.assertEqual(result["colors"]["focus"], "#408899ff")
        self.assertEqual(result["style"]["controlHeight"], 28)

    def test_legacy_style_and_controls_follow_merged_insertion_order(self):
        (self.theme / "shell.toml").write_text('[controls]\nselected-fill-alpha=0.2\n')
        self.user.write_text('[style]\nselected-fill-alpha=0.8\n')
        self.assertEqual(self.read()["colors"]["selection"], "#cceeeeff")
        # Reversing section names retains the same last-inserted-key behavior.
        (self.theme / "shell.toml").write_text('[style]\nselected-fill-alpha=0.2\n')
        self.user.write_text('[controls]\nselected-fill-alpha=0.8\n')
        self.assertEqual(self.read()["colors"]["selection"], "#cceeeeff")
        # Replacing an existing merged key does not move its insertion position,
        # matching Color.mergeShell followed by Style.applyShellValues.
        (self.theme / "shell.toml").write_text('[controls]\nselected-fill-alpha=0.2\n[style]\nselected-fill-alpha=0.4\n')
        self.user.write_text('[controls]\nselected-fill-alpha=0.8\n')
        self.assertEqual(self.read()["colors"]["selection"], "#66eeeeff")

    def test_invalid_and_oversize_sources(self):
        for invalid in ('background = "broken"\nforeground="#fff"', 'background=[\n', 'x="' + 'a' * bridge.MAX_BYTES):
            (self.theme / "colors.toml").write_text(invalid)
            with self.assertRaises(ValueError):
                self.read()

    def test_missing_and_malformed_cli_emit_clear_unavailable(self):
        for content in (None, 'background="private unexpected value"\n'):
            source = self.theme / "colors.toml"
            if content is None:
                source.unlink()
            else:
                source.write_text(content)
            result = json.loads(subprocess.check_output(["python3", str(INTEGRATION / "read_theme.py"), "--theme-dir", str(self.theme), "--user-shell", str(self.user), "--no-system"], text=True))
            self.assertFalse(result["available"])
            self.assertEqual(result["snapshot"], {})
            self.assertNotIn("private unexpected value", result["error"])

    def test_atomic_theme_and_symlink_replacement(self):
        old = self.root / "old"
        self.theme.rename(old)
        self.theme.symlink_to(old, target_is_directory=True)
        self.assertEqual(self.read()["colors"]["accent"], "#8899ff")
        other = self.root / "other"
        other.mkdir()
        (other / "colors.toml").write_text(PALETTE.replace("#8899ff", "#ffaa33"))
        link = self.root / "next"
        link.symlink_to(other, target_is_directory=True)
        link.replace(self.theme)
        self.assertEqual(self.read()["colors"]["accent"], "#ffaa33")
        self.theme.unlink()
        other.rename(self.theme)
        self.assertEqual(self.read()["colors"]["accent"], "#ffaa33")

    def test_read_only_system_commands_bounded_and_optional(self):
        with patch.object(bridge.subprocess, "run") as run:
            run.side_effect = [subprocess.CompletedProcess([], 0, "Fixture Mono", ""), subprocess.CompletedProcess([], 0, '{"int":17}', "")]
            result = bridge.snapshot(self.theme, self.user)
            self.assertEqual(result["style"]["fontFamily"], "Fixture Mono")
            self.assertEqual(result["style"]["radius"], 17)
            self.assertEqual(run.call_args_list[1].args[0], ["hyprctl", "-j", "getoption", "decoration:rounding"])
            for call in run.call_args_list:
                self.assertLessEqual(call.kwargs["timeout"], .5)
                self.assertNotIn("shell", call.kwargs)
        with patch.object(bridge.subprocess, "run") as run:
            self.read()
            run.assert_not_called()
        with patch.object(bridge.subprocess, "run", side_effect=subprocess.TimeoutExpired("fixture", .5)):
            result = bridge.snapshot(self.theme, self.user)
            self.assertEqual(result["style"]["radius"], 0)
            self.assertEqual(result["style"]["fontFamily"], "monospace")

    @unittest.skipUnless(shutil.which("quickshell"), "Quickshell required for native bridge polling")
    def test_native_live_source_creation_replacement_failure_and_disable(self):
        integration = self.root / "integration"
        shutil.copytree(INTEGRATION, integration)
        runtime = self.root / "runtime"
        runtime.mkdir(mode=0o700)
        control = self.root / "control"
        control.write_text("disabled")
        qml = self.root / "shell.qml"
        qml.write_text('''import QtQuick
import Quickshell
import Quickshell.Io
import "integration" as Host
ShellRoot {
    Host.DesktopThemeSource {
        id: source
        refreshInterval: 250
        querySystem: false
        themeDirectory: %s
        userShellPath: %s
        onResultChanged: console.log("BRIDGE " + JSON.stringify({available:available, error:error, name:name, tokens:tokens}))
        onLoadingChanged: console.log("LOADING " + loading)
    }
    FileView {
        id: control
        path: %s
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            source.enabled = text().trim() === "enabled"
            console.log("ENABLED " + source.enabled)
        }
    }
    Timer { interval: 20000; running: true; onTriggered: Qt.quit() }
}
''' % (json.dumps(str(self.theme)), json.dumps(str(self.user)), json.dumps(str(control))))
        environment = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software", XDG_RUNTIME_DIR=str(runtime))
        log = self.root / "native.log"
        with log.open("w") as output:
            process = subprocess.Popen(["quickshell", "-p", str(qml)], stdout=output, stderr=subprocess.STDOUT, env=environment)
            try:
                def wait_for(predicate):
                    until = time.monotonic() + 5
                    while time.monotonic() < until:
                        text = log.read_text()
                        if predicate(text):
                            return text
                        if process.poll() is not None:
                            self.fail("Native bridge exited: " + text)
                        time.sleep(.05)
                    self.fail("Native bridge timed out: " + log.read_text())

                wait_for(lambda text: "ENABLED false" in text)
                time.sleep(.35)
                self.assertNotIn("LOADING true", log.read_text())
                (self.theme / "colors.toml").unlink()
                control.write_text("enabled")
                wait_for(lambda text: '"available":false' in text)
                (self.theme / "colors.toml").write_text(PALETTE)
                wait_for(lambda text: '"primary":"#8899ff"' in text)
                replacement = self.root / "next-theme"
                replacement.mkdir()
                (replacement / "colors.toml").write_text(PALETTE.replace("#8899ff", "#ffaa33"))
                self.theme.rename(self.root / "old-theme")
                replacement.rename(self.theme)
                wait_for(lambda text: '"primary":"#ffaa33"' in text)
                self.user.write_text('[font]\nbase-size=20\n')
                wait_for(lambda text: '"fontSize":20' in text)
                (self.theme / "colors.toml").write_text("malformed [")
                wait_for(lambda text: text.rfind('"available":false') > text.rfind('"fontSize":20'))
                (self.theme / "colors.toml").write_text(PALETTE.replace("#8899ff", "#55dd99"))
                wait_for(lambda text: '"primary":"#55dd99"' in text)
                shutil.rmtree(self.theme)
                wait_for(lambda text: text.rfind('"available":false') > text.rfind('"primary":"#55dd99"'))
                control.write_text("disabled")
                wait_for(lambda text: text.rfind("ENABLED false") > text.rfind("ENABLED true"))
                time.sleep(.1)
                offset = len(log.read_text())
                time.sleep(.55)
                self.assertNotIn("LOADING true", log.read_text()[offset:])
                output_text = log.read_text()
                self.assertNotIn("ReferenceError", output_text)
                self.assertNotIn("TypeError", output_text)
                self.assertNotIn("WARN", output_text)
            finally:
                process.terminate()
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=3)


if __name__ == "__main__":
    unittest.main()
