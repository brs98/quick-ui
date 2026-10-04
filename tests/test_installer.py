"""Exercise the real CLI against temporary projects and a local registry fixture."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bundle = self.root / "bundle"
        self.bundle.mkdir()
        shutil.copy2(ROOT / "quickui", self.bundle / "quickui")
        shutil.copy2(ROOT / "registry.json", self.bundle / "registry.json")
        self.registry = json.loads((self.bundle / "registry.json").read_text())
        self.sources = self.bundle / "registry/quickui"
        self.sources.mkdir(parents=True)
        # Fixture content is deliberately independent of the production controls.
        # This verifies byte-for-byte copying without requiring a QML runtime.
        for entry in self.registry["components"].values():
            (self.sources / entry["file"]).write_text(f"// fixture {entry['file']}\nimport QtQuick\nQtObject {{}}\n")
        self.project = self.root / "project with spaces"
        self.project.mkdir()
        (self.project / "shell.qml").write_text("// user's shell\n")

    def run_cli(self, *args, success=True):
        result = subprocess.run([sys.executable, str(self.bundle / "quickui"), *args],
                                cwd=self.project, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        return result

    def init(self):
        self.run_cli("init", "--cwd", str(self.project))

    def save_registry(self):
        (self.bundle / "registry.json").write_text(json.dumps(self.registry))

    def snapshot(self):
        return {str(path.relative_to(self.project)): path.read_bytes()
                for path in self.project.rglob("*") if path.is_file()}

    def test_init_installs_theme_without_changing_shell(self):
        self.init()
        self.assertEqual(json.loads((self.project / "quickui.json").read_text()),
                         {"schemaVersion": 1, "componentsDir": "ui"})
        self.assertEqual((self.project / "ui/Theme.qml").read_bytes(),
                         (self.sources / "Theme.qml").read_bytes())
        self.assertEqual((self.project / "shell.qml").read_text(), "// user's shell\n")

    def test_add_resolves_transitive_dependencies_and_preserves_bytes(self):
        self.init()
        self.run_cli("add", "icon-button", "slider", "--cwd", str(self.project))
        self.assertEqual({path.name for path in (self.project / "ui").iterdir()},
                         {"Theme.qml", "Button.qml", "IconButton.qml", "Slider.qml"})
        for target in (self.project / "ui").iterdir():
            self.assertEqual(target.read_bytes(), (self.sources / target.name).read_bytes())

    def test_all_declared_components_install(self):
        self.init()
        self.run_cli("add", *self.registry["components"])
        self.assertEqual(len(list((self.project / "ui").iterdir())), 11)

    def test_list_does_not_mutate(self):
        before = self.snapshot()
        result = self.run_cli("list")
        for name in self.registry["components"]:
            self.assertIn(name, result.stdout)
        self.assertEqual(before, self.snapshot())

    def test_repeat_init_and_add_are_noops(self):
        self.init()
        self.run_cli("add", "button")
        before = self.snapshot()
        timestamps = {path: path.stat().st_mtime_ns for path in self.project.rglob("*")}
        self.run_cli("init")
        result = self.run_cli("add", "button", "button")
        self.assertIn("Unchanged", result.stdout)
        self.assertEqual(before, self.snapshot())
        self.assertEqual(timestamps, {path: path.stat().st_mtime_ns for path in timestamps})

    def test_init_dry_run_has_no_writes(self):
        before = self.snapshot()
        result = self.run_cli("init", "--dry-run")
        self.assertIn("Would create ui/Theme.qml", result.stdout)
        self.assertEqual(before, self.snapshot())
        self.assertFalse((self.project / "ui").exists())

    def test_add_dry_run_has_no_writes(self):
        self.init()
        before = self.snapshot()
        self.run_cli("add", "icon-button", "--dry-run")
        self.assertEqual(before, self.snapshot())

    def test_add_requires_init(self):
        self.assertIn("init", self.run_cli("add", "button", success=False).stderr)
        self.assertFalse((self.project / "ui").exists())

    def test_unknown_component_has_no_partial_writes(self):
        self.init()
        before = self.snapshot()
        self.run_cli("add", "button", "missing", success=False)
        self.assertEqual(before, self.snapshot())

    def test_conflicts_have_no_partial_writes(self):
        self.init()
        target = self.project / "ui/Slider.qml"
        for dry_run in ([], ["--dry-run"]):
            target.write_text("// custom or unrelated source")
            before = self.snapshot()
            result = self.run_cli("add", "button", "slider", *dry_run, success=False)
            self.assertIn("Refusing to overwrite", result.stderr)
            self.assertEqual(before, self.snapshot())

    def test_edited_dependency_blocks_install(self):
        self.init()
        (self.project / "ui/Theme.qml").write_text("// customized theme")
        self.run_cli("add", "icon-button", success=False)
        self.assertFalse((self.project / "ui/Button.qml").exists())

    def test_init_conflict_does_not_write_metadata(self):
        (self.project / "ui").mkdir()
        (self.project / "ui/Theme.qml").write_text("unrelated")
        self.run_cli("init", success=False)
        self.assertFalse((self.project / "quickui.json").exists())

    def test_custom_components_directory(self):
        (self.project / "quickui.json").write_text(json.dumps({"schemaVersion": 1, "componentsDir": "components/ui"}))
        self.run_cli("init")
        self.run_cli("add", "button")
        self.assertTrue((self.project / "components/ui/Button.qml").is_file())
        self.assertFalse((self.project / "ui").exists())

    def test_invalid_metadata(self):
        for content in ("{", "[]", '{"schemaVersion":2,"componentsDir":"ui"}',
                        '{"schemaVersion":1}', '{"schemaVersion":1,"schemaVersion":1,"componentsDir":"ui"}'):
            with self.subTest(content=content):
                (self.project / "quickui.json").write_text(content)
                self.run_cli("init", success=False)
                self.assertFalse((self.project / "ui").exists())

    def test_unsafe_components_directories(self):
        for directory in ("../escape", "/tmp/escape", "ui/../../escape", "ui/../other", ".", "", "ui//nested", "ui/", "C:\\escape", "ui\x00bad", "ui\nname", None):
            with self.subTest(directory=directory):
                (self.project / "quickui.json").write_text(json.dumps({"schemaVersion": 1, "componentsDir": directory}))
                self.run_cli("init", success=False)
        self.assertFalse((self.root / "escape").exists())

    def test_symlink_metadata_rejected_even_when_dangling(self):
        target = self.root / "outside.json"
        metadata = self.project / "quickui.json"
        metadata.symlink_to(target)
        self.run_cli("init", success=False)
        self.assertFalse(target.exists())
        target.write_text('{"schemaVersion":1,"componentsDir":"ui"}')
        self.run_cli("init", success=False)
        self.assertFalse((self.project / "ui").exists())

    def test_symlink_output_directory_rejected(self):
        outside = self.root / "outside"
        outside.mkdir()
        (self.project / "ui").symlink_to(outside, target_is_directory=True)
        self.run_cli("init", success=False)
        self.assertEqual(list(outside.iterdir()), [])
        self.assertFalse((self.project / "quickui.json").exists())

    def test_symlink_destination_rejected(self):
        self.init()
        outside = self.root / "outside.qml"
        (self.project / "ui/Button.qml").symlink_to(outside)
        self.run_cli("add", "button", success=False)
        self.assertFalse(outside.exists())

    def test_non_directory_ancestor_rejected(self):
        (self.project / "ui").write_text("unrelated")
        self.run_cli("init", success=False)
        self.assertFalse((self.project / "quickui.json").exists())

    def test_directory_destination_rejected(self):
        (self.project / "ui/Theme.qml").mkdir(parents=True)
        self.run_cli("init", success=False)
        self.assertFalse((self.project / "quickui.json").exists())

    def test_missing_source_has_no_partial_writes(self):
        self.init()
        (self.sources / "Slider.qml").unlink()
        before = self.snapshot()
        self.run_cli("add", "button", "slider", success=False)
        self.assertEqual(before, self.snapshot())

    def test_symlink_registry_and_source_rejected(self):
        source = self.sources / "Theme.qml"
        outside = self.root / "outside.qml"
        source.rename(outside)
        source.symlink_to(outside)
        self.run_cli("init", success=False)
        source.unlink()
        outside.rename(source)
        metadata = self.bundle / "registry.json"
        metadata.rename(self.root / "outside.json")
        metadata.symlink_to(self.root / "outside.json")
        self.run_cli("init", success=False)
        self.assertFalse((self.project / "quickui.json").exists())

    def test_invalid_registry_graphs_and_paths(self):
        original = json.dumps(self.registry)
        mutations = [
            lambda e: e["theme"].update(dependencies=["button"]),
            lambda e: e["button"].update(dependencies=["missing"]),
            lambda e: e["button"].update(dependencies="theme"),
            lambda e: e["button"].update(file="../Button.qml"),
            lambda e: e["button"].update(file="/Button.qml"),
            lambda e: e["button"].update(file="Theme.qml"),
        ]
        for mutate in mutations:
            self.registry = json.loads(original)
            mutate(self.registry["components"])
            self.save_registry()
            self.run_cli("init", success=False)
            self.assertFalse((self.project / "quickui.json").exists())

    def test_malformed_registry(self):
        for content in ("{", "[]", '{"schemaVersion":1,"components":[]}', '{"schemaVersion":2}'):
            (self.bundle / "registry.json").write_text(content)
            self.run_cli("list", success=False)

    def test_nonexistent_project_rejected(self):
        self.run_cli("init", "--cwd", str(self.root / "missing"), success=False)
        self.assertFalse((self.root / "missing").exists())


if __name__ == "__main__":
    unittest.main()
