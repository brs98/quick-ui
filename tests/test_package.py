import hashlib
import importlib.util
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("release_package", Path(__file__).resolve().parents[1] / "scripts/package.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class PackageTest(unittest.TestCase):
    def test_release_uses_commit_not_untracked_files_and_is_reproducible(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "repo"
            root.mkdir()
            def git(*args):
                return subprocess.run(["git", "-C", str(root), *args], check=True, capture_output=True)
            git("init")
            git("config", "user.name", "Test")
            git("config", "user.email", "test@example.invalid")
            (root / "VERSION").write_text("0.2.0\n")
            (root / "quickui").write_text("#!/bin/sh\nexit 0\n")
            (root / "quickui").chmod(0o755)
            git("add", ".")
            git("commit", "-m", "fixture")
            (root / "untracked.txt").write_text("not release content")
            a = module.package(root, Path(directory) / "a", "v0.2.0")
            b = module.package(root, Path(directory) / "b")
            self.assertEqual(a.read_bytes(), b.read_bytes())
            self.assertEqual((a.parent / "SHA256SUMS").read_text(), hashlib.sha256(a.read_bytes()).hexdigest() + "  " + a.name + "\n")
            with tarfile.open(a) as tar:
                self.assertNotIn("quick-ui-0.2.0/untracked.txt", tar.getnames())
                self.assertEqual(tar.getmember("quick-ui-0.2.0/quickui").mode & 0o111, 0o111)
            with self.assertRaisesRegex(ValueError, "Tag"):
                module.package(root, a.parent, "v0.3.0")
            (root / "VERSION").write_text("0.3.0\n")
            with self.assertRaisesRegex(ValueError, "Commit"):
                module.package(root, a.parent)
