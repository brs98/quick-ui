"""Portable installation, ownership, and rollback contracts."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
SPEC = importlib.util.spec_from_file_location("user_install", ROOT / "scripts/install.py")
INSTALL = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(INSTALL)


class UserInstallTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="quickui-install-test-")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.source = self.directory / "release"
        self.source.mkdir()
        for path in INSTALL.source_files(ROOT):
            destination = self.source / path.relative_to(ROOT)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(str(path), str(destination))
        (self.source / "VERSION").write_text("0.2.0\n")
        self.prefix = self.directory / "user's apps $HOME `test` %q"

    def install(self, **options):
        with contextlib.redirect_stdout(io.StringIO()):
            INSTALL.install(self.source, self.prefix, **options)

    def snapshot(self):
        return {str(path.relative_to(self.prefix)): (path.read_bytes(), path.stat().st_mode)
                for path in self.prefix.rglob("*") if path.is_file()}

    def run_cli(self, *args):
        env = dict(os.environ, HOME=str(self.directory / "home"))
        return subprocess.run([str(self.prefix / "bin/quickui")] + list(args),
                              cwd=str(self.directory), env=env, text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def test_standalone_install_launchers_and_desktop(self):
        self.install()
        self.assertFalse((self.prefix / INSTALL.APP / ".git").exists())
        result = self.run_cli("list")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("button", result.stdout)
        project = self.directory / "consumer project"
        project.mkdir()
        result = self.run_cli("init", "--cwd", str(project))
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.run_cli("add", "button", "--cwd", str(project))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((project / "ui/Button.qml").is_file())
        fake_bin = self.directory / "fake-bin"
        fake_bin.mkdir()
        fake_shell = fake_bin / "quickshell"
        fake_shell.write_text("#!/usr/bin/env python3\nimport json, sys\nprint(json.dumps(sys.argv[1:]))\n")
        fake_shell.chmod(0o755)
        result = subprocess.run([str(self.prefix / "bin/quickbook"), "--help"],
                                cwd=str(self.directory), text=True, capture_output=True,
                                env=dict(os.environ, PATH=str(fake_bin) + os.pathsep + os.environ["PATH"]))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), ["-p", str(self.prefix / INSTALL.APP / "shell.qml"), "--help"])
        desktop = self.prefix / "share/applications/quickbook.desktop"
        self.assertIn("Exec=/bin/sh " + INSTALL.exec_quote(str(self.prefix / "bin/quickbook")), desktop.read_text())
        validator = shutil.which("desktop-file-validate")
        if validator:
            result = subprocess.run([validator, str(desktop)], text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        gio = shutil.which("gio")
        if gio:
            result = subprocess.run([gio, "launch", str(desktop)], text=True, capture_output=True,
                                    timeout=10,
                                    env=dict(os.environ, QT_QPA_PLATFORM="offscreen",
                                             PATH=str(fake_bin) + os.pathsep + os.environ["PATH"]))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout), ["-p", str(self.prefix / INSTALL.APP / "shell.qml")])
        # Runtime imports must not pollute the managed snapshot with bytecode.
        self.assertFalse(list((self.prefix / INSTALL.APP).rglob("__pycache__")))
        self.install()

    def test_dry_run_does_not_create_prefix(self):
        self.install(dry_run=True)
        self.assertFalse(self.prefix.exists())

    def test_reinstall_is_noop_and_update_removes_obsolete_files(self):
        obsolete = self.source / "app/Obsolete.qml"
        obsolete.write_text("import QtQuick\nItem {}\n")
        self.install()
        before = self.snapshot()
        manifest = self.prefix / INSTALL.MANIFEST
        stamp = manifest.stat().st_mtime_ns
        self.install()
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(manifest.stat().st_mtime_ns, stamp)
        obsolete.unlink()
        (self.source / "VERSION").write_text("0.2.1\n")
        self.install(dry_run=True)
        self.assertEqual(self.snapshot(), before)
        self.install()
        self.assertFalse((self.prefix / INSTALL.APP / "app/Obsolete.qml").exists())
        self.assertEqual(json.loads(manifest.read_text())["version"], "0.2.1")

    def test_conflicts_preserve_files(self):
        (self.prefix / "bin").mkdir(parents=True)
        conflict = self.prefix / "bin/quickui"
        conflict.write_text("user script")
        with self.assertRaisesRegex(INSTALL.InstallError, "Unowned"):
            self.install()
        self.assertEqual(conflict.read_text(), "user script")
        self.assertFalse((self.prefix / INSTALL.APP).exists())

    def test_modified_or_extra_installed_files_block_update_and_uninstall(self):
        self.install()
        modified = self.prefix / INSTALL.APP / "registry/quickui/Button.qml"
        modified.write_text(modified.read_text() + "\n// custom\n")
        before = self.snapshot()
        for options in ({}, {"dry_run": True}, {"uninstall": True}):
            with self.assertRaisesRegex(INSTALL.InstallError, "Installed files changed"):
                self.install(**options)
        self.assertEqual(self.snapshot(), before)
        modified.write_text((self.source / "registry/quickui/Button.qml").read_text())
        (self.prefix / INSTALL.APP / "mine.txt").write_text("my data")
        with self.assertRaisesRegex(INSTALL.InstallError, "mine.txt"):
            self.install()

    def test_symlink_destination_rejected(self):
        self.prefix.mkdir()
        elsewhere = self.directory / "elsewhere"
        elsewhere.mkdir()
        (self.prefix / "bin").symlink_to(elsewhere, target_is_directory=True)
        with self.assertRaisesRegex(INSTALL.InstallError, "symlink"):
            self.install()
        self.assertEqual(list(elsewhere.iterdir()), [])

    def test_update_failure_rolls_back(self):
        self.install()
        before = self.snapshot()
        (self.source / "VERSION").write_text("0.2.1\n")
        replace = INSTALL.os.replace
        count = [0]

        def fail_once(source, destination):
            count[0] += 1
            if count[0] == 5:
                raise OSError("simulated disk failure")
            return replace(source, destination)

        with mock.patch.object(INSTALL.os, "replace", side_effect=fail_once):
            with self.assertRaisesRegex(OSError, "simulated"):
                self.install()
        self.assertEqual(self.snapshot(), before)
        self.assertFalse((self.prefix / ".quick-ui-install.lock").exists())
        self.install()

    def test_failed_rollback_preserves_recovery_files(self):
        self.install()
        original = (self.prefix / INSTALL.APP / "VERSION").read_bytes()
        (self.source / "VERSION").write_text("0.2.1\n")
        replace = INSTALL.os.replace
        count = [0]

        def fail_twice(source, destination):
            count[0] += 1
            if count[0] in (5, 6):
                raise OSError("filesystem unavailable")
            return replace(source, destination)

        with mock.patch.object(INSTALL.os, "replace", side_effect=fail_twice):
            with self.assertRaisesRegex(INSTALL.RecoveryError, "recovery files preserved"):
                self.install()
        recovery = list(self.prefix.glob(".quick-ui-stage-*"))
        self.assertEqual(len(recovery), 1)
        self.assertEqual((recovery[0] / ".backup" / INSTALL.APP / "VERSION").read_bytes(), original)

    def test_uninstall_preserves_consumer_and_state(self):
        self.install()
        state = self.directory / "home/.local/state/quickbook/session.json"
        state.parent.mkdir(parents=True)
        state.write_text("saved session")
        unrelated = self.prefix / "bin/other-program"
        unrelated.write_text("other")
        self.install(uninstall=True, dry_run=True)
        self.assertTrue((self.prefix / INSTALL.MANIFEST).exists())
        self.install(uninstall=True)
        for relative in INSTALL.TARGETS + (INSTALL.MANIFEST,):
            self.assertFalse((self.prefix / relative).exists())
        self.assertEqual(state.read_text(), "saved session")
        self.assertEqual(unrelated.read_text(), "other")

    def test_installed_copy_can_uninstall_itself(self):
        self.install()
        result = subprocess.run([sys.executable, str(self.prefix / INSTALL.APP / "scripts/install.py"),
                                 "--prefix", str(self.prefix), "--uninstall"],
                                cwd=str(self.directory), text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.prefix / INSTALL.APP).exists())

    def test_temp_home_default_and_incomplete_snapshot(self):
        home = self.directory / "home"
        result = subprocess.run([sys.executable, str(self.source / "scripts/install.py"), "--dry-run"],
                                env=dict(os.environ, HOME=str(home)), text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(str(home / ".local"), result.stdout)
        self.assertFalse(home.exists())
        (self.source / "shell.qml").unlink()
        with self.assertRaisesRegex(INSTALL.InstallError, "Incomplete"):
            self.install()
        self.assertFalse(self.prefix.exists())


if __name__ == "__main__":
    unittest.main()
