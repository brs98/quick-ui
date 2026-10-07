"""Optional recipe handoff, strict inputs, and transactional source ownership."""
import copy
import hashlib
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import omarchy_recipe

RECIPE = {"schemaVersion": 1, "kind": "quickui-omarchy", "preset": "q1-6bi",
          "follow": {"colors": True, "typography": True, "radius": True, "spacing": True},
          "radiusMultiplier": 1}


class OmarchyInstallTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.project = Path(temporary.name)
        self.recipe = self.project / "recipe.json"
        self.recipe.write_text(json.dumps(RECIPE))
        self.cli("init")

    def cli(self, *arguments, success=True):
        result = subprocess.run([sys.executable, str(ROOT / "quickui"), *arguments], cwd=self.project,
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        return result

    def install(self, *arguments, success=True):
        return self.cli("omarchy", "install", "--recipe", str(self.recipe), *arguments, success=success)

    def snapshot(self):
        return {str(path.relative_to(self.project)): (path.read_bytes(), path.stat().st_mtime_ns)
                for path in self.project.rglob("*") if path.is_file() and not path.is_symlink()}

    def test_install_recipe_and_sources_custom_directory(self):
        (self.project / "quickui.json").write_text(json.dumps({"schemaVersion": 1, "componentsDir": "qml/owned"}))
        self.install()
        config = json.loads((self.project / "quickui.json").read_text())
        self.assertEqual(config["omarchy"]["recipe"], RECIPE)
        self.assertEqual(len(config["omarchy"]["files"]), 7)
        for path, fingerprint in config["omarchy"]["files"].items():
            self.assertEqual(fingerprint, hashlib.sha256((self.project / path).read_bytes()).hexdigest())
        wrapper = (self.project / "qml/owned/OmarchyPreset.qml").read_text()
        self.assertIn("presetTheme: PresetTheme {}", wrapper)
        self.assertIn("followTypography: true", wrapper)
        self.assertIn("Permission is hereby granted", wrapper)
        self.assertEqual(config["preset"]["path"], "qml/owned/PresetTheme.qml")
        self.assertTrue((self.project / "qml/owned/Theme.qml").exists())
        self.assertEqual((self.project / "qml/owned/HostTheme.qml").read_bytes(),
                         (ROOT / "registry/quickui/HostTheme.qml").read_bytes())

    def test_preserves_custom_components_and_theme(self):
        self.cli("add", "button")
        for filename in ("Theme.qml", "Button.qml"):
            path = self.project / "ui" / filename
            path.write_bytes(path.read_bytes() + b"\n// mine\n")
        before = self.snapshot()
        self.install()
        after = self.snapshot()
        for filename in ("Theme.qml", "Button.qml"):
            self.assertEqual(before["ui/" + filename], after["ui/" + filename])

    def test_dry_run_and_noop_preserve_content_timestamps(self):
        before = self.snapshot()
        self.install("--dry-run")
        self.assertEqual(before, self.snapshot())
        self.assertFalse((self.project / "quickui-omarchy").exists())
        self.install()
        before = self.snapshot()
        self.install()
        self.assertEqual(before, self.snapshot())
        updated = copy.deepcopy(RECIPE)
        updated["preset"] = "q1-6j6"
        self.recipe.write_text(json.dumps(updated))
        before = self.snapshot()
        self.install("--dry-run")
        self.assertEqual(before, self.snapshot())

    def test_recipe_changes_update_generated_files_only(self):
        self.install()
        source = self.project / "quickui-omarchy/DesktopThemeSource.qml"
        original = (source.read_bytes(), source.stat().st_mtime_ns)
        recipe = copy.deepcopy(RECIPE)
        recipe["follow"]["spacing"] = False
        recipe["radiusMultiplier"] = .5
        recipe["preset"] = "q1-6j6"
        self.recipe.write_text(json.dumps(recipe))
        self.install()
        self.assertEqual(original, (source.read_bytes(), source.stat().st_mtime_ns))
        wrapper = (self.project / "ui/OmarchyPreset.qml").read_text()
        self.assertIn("followSpacing: false", wrapper)
        self.assertIn("radiusMultiplier: 0.5", wrapper)
        config = json.loads((self.project / "quickui.json").read_text())
        self.assertEqual(config["preset"]["code"], "q1-6j6")

    def test_edited_optional_file_aborts_entire_plan(self):
        self.install()
        path = self.project / "quickui-omarchy/ShellThemeSource.qml"
        path.write_bytes(path.read_bytes() + b"\n// mine\n")
        recipe = dict(RECIPE, preset="q1-6j6")
        self.recipe.write_text(json.dumps(recipe))
        before = self.snapshot()
        self.assertIn("edited or unowned", self.install(success=False).stderr)
        self.assertEqual(before, self.snapshot())

    def test_even_identical_unowned_optional_file_is_preserved(self):
        path = self.project / "ui/HostTheme.qml"
        path.write_bytes((ROOT / "registry/quickui/HostTheme.qml").read_bytes())
        before = self.snapshot()
        self.install(success=False)
        self.assertEqual(before, self.snapshot())

    def test_existing_owned_preset_is_updated_but_edited_preset_blocks(self):
        self.cli("preset", "apply", "q1-6j6")
        self.install()
        preset = self.project / "ui/PresetTheme.qml"
        preset.write_bytes(preset.read_bytes() + b"\n// edited\n")
        before = self.snapshot()
        self.install(success=False)
        self.assertEqual(before, self.snapshot())

    def test_metadata_changes_and_symlinks_are_rejected(self):
        self.install()
        metadata = self.project / "quickui.json"
        original = metadata.read_text()
        config = json.loads(original)
        for invalid in (dict(config["omarchy"], schemaVersion=True),
                        dict(config["omarchy"], files={"../bad": "a" * 64})):
            metadata.write_text(json.dumps(dict(config, omarchy=invalid)))
            before = self.snapshot()
            self.install(success=False)
            self.assertEqual(before, self.snapshot())
        metadata.write_text(original)
        source = self.project / "quickui-omarchy/read_theme.py"
        source.unlink()
        source.symlink_to(self.recipe)
        before = self.snapshot()
        self.install(success=False)
        self.assertEqual(before, self.snapshot())

    def test_destination_move_requires_deliberate_migration(self):
        self.install()
        path = self.project / "quickui.json"
        config = json.loads(path.read_text())
        config["componentsDir"] = "new-ui"
        path.write_text(json.dumps(config))
        before = self.snapshot()
        self.install(success=False)
        self.assertEqual(before, self.snapshot())
        self.assertFalse((self.project / "new-ui").exists())

    def test_no_init_and_duplicate_keys_are_rejected(self):
        (self.project / "quickui.json").unlink()
        before = self.snapshot()
        self.install(success=False)
        self.assertEqual(before, self.snapshot())
        self.recipe.write_text('{"schemaVersion":1,"schemaVersion":1}')
        self.assertIn("Duplicate JSON key", self.install(success=False).stderr)

    def test_existing_registry_host_theme_can_be_adopted(self):
        content = (ROOT / "registry/quickui/HostTheme.qml").read_bytes()
        (self.project / "ui/HostTheme.qml").write_bytes(content)
        metadata = self.project / "quickui.json"
        config = json.loads(metadata.read_text())
        config["installed"]["host-theme"] = {"path": "ui/HostTheme.qml", "sha256": hashlib.sha256(content).hexdigest()}
        metadata.write_text(json.dumps(config))
        self.install()
        config = json.loads(metadata.read_text())
        self.assertEqual(config["omarchy"]["files"]["ui/HostTheme.qml"], config["installed"]["host-theme"]["sha256"])

    def test_installed_composition_updates_and_preserves_motion_override(self):
        runner = os.environ.get("QMLTESTRUNNER", "/usr/lib/qt6/bin/qmltestrunner")
        if not Path(runner).is_file():
            self.skipTest("Qt qmltestrunner unavailable")
        self.install()
        (self.project / "tst_installed.qml").write_text('''import QtQuick
import QtTest
import "ui" as UI
TestCase {
    name: "InstalledOmarchyRecipe"
    UI.OmarchyPreset { id: theme }
    function initTestCase() { failOnWarning(/.*/); }
    function test_live_and_fallback() {
        let fallback = theme.radius;
        let motion = theme.motionDuration;
        theme.hostTokens = {radius: 20, fontSize: 18, motionDuration: 9999, accent: "#112233"};
        compare(theme.radius, 20);
        compare(theme.fontSize, 18);
        compare(theme.accent.toString(), "#112233");
        compare(theme.motionDuration, motion);
        theme.radiusMultiplier = 0.5;
        compare(theme.radius, 10);
        theme.hostTokens = {radius: 8};
        compare(theme.radius, 4);
        theme.hostTokens = null;
        compare(theme.radius, fallback);
    }
}
''')
        runtime = self.project / "runtime"
        runtime.mkdir(mode=0o700)
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software", XDG_RUNTIME_DIR=str(runtime))
        result = subprocess.run([runner, "-input", str(self.project / "tst_installed.qml")],
                                env=env, capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_rollback_when_second_atomic_creation_fails(self):
        loader = importlib.machinery.SourceFileLoader("omarchy_cli_test", str(ROOT / "quickui"))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        cli = importlib.util.module_from_spec(spec)
        loader.exec_module(cli)
        first, second = self.project / "new/a.qml", self.project / "new/b.qml"
        real_link = cli.os.link
        def failing_link(source, destination):
            if destination == second:
                raise OSError("synthetic disk failure")
            return real_link(source, destination)
        before = self.snapshot()
        with patch.object(cli.os, "link", side_effect=failing_link), self.assertRaises(OSError):
            cli.commit_plan(self.project, [(first, b"a", None), (second, b"b", None)])
        self.assertEqual(before, self.snapshot())
        self.assertFalse((self.project / "new").exists())


class RecipeValidationTests(unittest.TestCase):
    def test_exact_schema_and_values(self):
        self.assertEqual(omarchy_recipe.validate(RECIPE), RECIPE)
        invalid = [dict(RECIPE, schemaVersion=True), dict(RECIPE, schemaVersion=2),
                   dict(RECIPE, kind="another"), dict(RECIPE, preset="q2-0"),
                   dict(RECIPE, extra=True), dict(RECIPE, follow={}),
                   dict(RECIPE, follow=dict(RECIPE["follow"], colors=1))]
        invalid += [dict(RECIPE, radiusMultiplier=value) for value in (True, "1", -1, 3, 10 ** 400, float("nan"), float("inf"))]
        for recipe in invalid:
            with self.subTest(recipe=recipe), self.assertRaises(ValueError):
                omarchy_recipe.validate(recipe)
