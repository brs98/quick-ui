"""Preset compatibility, native token parity, and consumer-source ownership."""
import hashlib
import importlib.machinery
import importlib.util
import itertools
import json
import math
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import presetlib as presets


def load_cli():
    loader = importlib.machinery.SourceFileLoader("quickui_cli", str(ROOT / "quickui"))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def luminance(color):
    values = [int(color[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    return sum((v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4) * w
               for v, w in zip(values, (.2126, .7152, .0722)))


class CodecTests(unittest.TestCase):
    def test_v1_meaning_is_frozen(self):
        # Changing option order OR token values changes existing shared codes.
        canonical = json.dumps(presets.CATALOG, sort_keys=True, separators=(",", ":")).encode()
        self.assertEqual(hashlib.sha256(canonical).hexdigest(),
                         "03062d2bafbe6ddb7d4c97f2fef4efb78f0162586a1295fc6691e2fbf0555d91")
        self.assertEqual(presets.encode(presets.defaults()), "q1-6bi")
        self.assertEqual(presets.decode("q1-6j6"), dict(presets.defaults(), accent="ocean", radius="large"))

    def test_entire_code_space_roundtrips_without_collisions(self):
        choices = [[v["value"] for v in group["values"]] for group in presets.OPTIONS]
        keys = [group["key"] for group in presets.OPTIONS]
        seen = set()
        for values in itertools.product(*choices):
            config = dict(zip(keys, values))
            code = presets.encode(config)
            self.assertNotIn(code, seen)
            seen.add(code)
            self.assertEqual(presets.decode(code), config)
        self.assertEqual(len(seen), math.prod(map(len, choices)))

    def test_invalid_codes_configs_and_envelopes_rejected(self):
        for code in (None, 1, "", "q2-0", "q1-00", "q1-A", "q1--1", " q1-0", "q1-0\n", "q1-zzzzzzzzzzzzzz"):
            with self.subTest(code=code), self.assertRaises(ValueError):
                presets.decode(code)
        for config in (None, [], {}, dict(presets.defaults(), accent="missing"),
                       dict(presets.defaults(), unexpected="value"), dict(presets.defaults(), radius=1)):
            with self.subTest(config=config), self.assertRaises(ValueError):
                presets.encode(config)
        exported = presets.export("q1-6bi")
        self.assertEqual(presets.import_config(exported), presets.defaults())
        for data in (dict(exported, code="q1-0"), dict(exported, schemaVersion=True),
                     dict(exported, schemaVersion=2), dict(exported, extra=True)):
            with self.assertRaises(ValueError):
                presets.import_config(data)

    def test_curated_text_contrast(self):
        for palette, accent, selection, dark in itertools.product(
                presets.CATALOG["palettes"], presets.CATALOG["accents"], ("subtle", "accent"), (False, True)):
            tokens = presets.resolve(dict(presets.defaults(), palette=palette, accent=accent, selection=selection), dark)
            pairs = [("foreground", bg) for bg in ("background", "surface", "surfaceHover")]
            pairs += [("mutedForeground", bg) for bg in ("background", "surface", "surfaceHover")]
            pairs += [(name + "Foreground", name) for name in ("accent", "primary", "selection", "destructive", "card", "popup")]
            for foreground, background in pairs:
                high, low = sorted((luminance(tokens[foreground]), luminance(tokens[background])), reverse=True)
                with self.subTest(palette=palette, accent=accent, selection=selection, dark=dark, pair=(foreground, background)):
                    self.assertGreaterEqual((high + .05) / (low + .05), 4.5)

    def test_generated_sources_are_current(self):
        subprocess.run([sys.executable, str(ROOT / "scripts/generate_presets.py"), "--check"], check=True)

    def test_native_js_and_generated_qml_match_python(self):
        runner = os.environ.get("QMLTESTRUNNER", "/usr/lib/qt6/bin/qmltestrunner")
        if not Path(runner).is_file():
            self.skipTest("Qt qmltestrunner unavailable")
        cases = [presets.defaults()]
        for option in presets.OPTIONS:
            cases.extend(dict(presets.defaults(), **{option["key"]: choice["value"]}) for choice in option["values"])
        cases.extend(dict(presets.defaults(), palette=palette, accent=accent, selection=selection)
                     for palette, accent, selection in itertools.product(presets.CATALOG["palettes"], presets.CATALOG["accents"], ("subtle", "accent")))
        expected = [{"config": config, "code": presets.encode(config), "dark": presets.resolve(config, True),
                     "light": presets.resolve(config, False)} for config in cases]
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            shutil.copy2(ROOT / "registry/quickui/Theme.qml", root / "Theme.qml")
            (root / "PresetTheme.qml").write_bytes(presets.qml_theme(presets.encode(dict(presets.defaults(), colorSource="system"))))
            test = '''import QtQuick
import QtTest
import "CODEC" as Codec
TestCase {
    name: "NativePresetParity"
    property var cases: CASES
    Theme { id: host; accent: "#123456" }
    PresetTheme { id: generated }
    function initTestCase() { failOnWarning(/.*/); }
    function test_parity() {
        for (let row of cases) {
            compare(Codec.encode(row.config), row.code);
            compare(Codec.decode(row.code), row.config);
            compare(Codec.resolve(row.config, true), row.dark);
            compare(Codec.resolve(row.config, false), row.light);
        }
        for (let dark of [true, false]) {
            generated.dark = dark;
            let expected = Codec.resolve(Codec.decode(generated.presetCode), dark);
            for (let key in expected) {
                if (typeof expected[key] === "string" && expected[key][0] === "#")
                    compare(generated[key].toString(), expected[key]);
                else compare(generated[key], expected[key]);
            }
        }
        generated.systemTheme = host;
        compare(generated.accent, host.accent);
        compare(generated.surface, host.surface);
        host.accent = "#abcdef";
        compare(generated.accent, host.accent);
        generated.systemTheme = null;
        compare(generated.accent.toString(), Codec.resolve(Codec.decode(generated.presetCode), generated.dark).accent);
    }
    function test_reject() {
        for (let code of ["q1-00", "q1-A", "q2-0", "q1-zzzzzzzzzzzzz", "q1-0\\n"]) {
            let rejected = false;
            try { Codec.decode(code); } catch (e) { rejected = true; }
            verify(rejected, code);
        }
    }
}
'''.replace("CODEC", (ROOT / "app/PresetCodec.js").as_uri()).replace("CASES", json.dumps(expected))
            (root / "tst_parity.qml").write_text(test)
            runtime = root / "runtime"
            runtime.mkdir(mode=0o700)
            env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software", XDG_RUNTIME_DIR=str(runtime))
            result = subprocess.run([runner, "-input", str(root / "tst_parity.qml")], env=env, capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class PresetCliTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.project = Path(self.temporary.name) / "consumer project"
        self.project.mkdir()
        self.code = "q1-6bi"
        self.other = "q1-6j6"

    def cli(self, *args, success=True):
        result = subprocess.run([sys.executable, str(ROOT / "quickui"), *args], cwd=self.project, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        return result

    def snapshot(self):
        return {str(p.relative_to(self.project)): (p.read_bytes(), p.stat().st_mtime_ns)
                for p in self.project.rglob("*") if p.is_file() and not p.is_symlink()}

    def init(self):
        self.cli("init", "--preset", self.code)

    def test_init_export_encode_inspect_and_license(self):
        self.init()
        generated = self.project / "ui/PresetTheme.qml"
        self.assertIn("Permission is hereby granted", generated.read_text())
        self.assertEqual((self.project / "ui/Theme.qml").read_bytes(), (ROOT / "registry/quickui/Theme.qml").read_bytes())
        envelope = self.cli("preset", "export", self.code).stdout
        (self.project / "preset.json").write_text(envelope)
        self.assertEqual(self.cli("preset", "encode", "preset.json").stdout.strip(), self.code)
        self.assertEqual(json.loads(self.cli("preset", "inspect", self.code, "--json").stdout), json.loads(envelope))
        self.assertIn("radius: default", self.cli("preset", "inspect", self.code).stdout)

    def test_apply_keeps_owned_sources_and_tracks_generated_file(self):
        self.init()
        self.cli("add", "button")
        for filename in ("Theme.qml", "Button.qml"):
            path = self.project / "ui" / filename
            path.write_bytes(path.read_bytes() + b"\n// consumer edit\n")
        before = self.snapshot()
        self.cli("preset", "apply", self.other)
        after = self.snapshot()
        for filename in ("Theme.qml", "Button.qml"):
            self.assertEqual(before["ui/" + filename], after["ui/" + filename])
        config = json.loads((self.project / "quickui.json").read_text())
        self.assertEqual(config["preset"]["code"], self.other)
        self.assertEqual(config["preset"]["sha256"], hashlib.sha256((self.project / "ui/PresetTheme.qml").read_bytes()).hexdigest())

    def test_dry_run_and_noop_preserve_bytes_and_timestamps(self):
        self.cli("init", "--preset", self.code, "--dry-run")
        self.assertEqual(list(self.project.iterdir()), [])
        self.init()
        before = self.snapshot()
        self.cli("preset", "apply", self.other, "--dry-run")
        self.assertEqual(self.snapshot(), before)
        self.cli("preset", "apply", self.code)
        self.cli("init", "--preset", self.code)
        self.assertEqual(self.snapshot(), before)

    def test_edited_and_unowned_presets_block_before_writes(self):
        self.init()
        target = self.project / "ui/PresetTheme.qml"
        target.write_bytes(target.read_bytes() + b"\n// edited\n")
        for dry in ([], ["--dry-run"]):
            before = self.snapshot()
            self.cli("preset", "apply", self.other, *dry, success=False)
            self.assertEqual(before, self.snapshot())
        (self.project / "quickui.json").unlink()
        (self.project / "ui/Theme.qml").unlink()
        before = self.snapshot()
        self.cli("init", "--preset", self.code, success=False)
        self.assertEqual(before, self.snapshot())

    def test_invalid_inputs_never_create_files(self):
        for code in ("q2-0", "q1-00", "q1-zzzzz"):
            self.cli("init", "--preset", code, success=False)
            self.assertEqual(list(self.project.iterdir()), [])
        self.cli("preset", "apply", self.code, success=False)
        self.assertEqual(list(self.project.iterdir()), [])
        path = self.project / "preset.json"
        for data in (dict(presets.export(self.code), code=self.other), {"schemaVersion": 2}):
            path.write_text(json.dumps(data))
            self.cli("preset", "encode", str(path), success=False)
        path.write_text('{"schemaVersion":1,"schemaVersion":1}')
        self.cli("preset", "encode", str(path), success=False)

    def test_custom_directory_and_changed_destination(self):
        path = self.project / "quickui.json"
        path.write_text(json.dumps({"schemaVersion": 1, "componentsDir": "components/ui", "notes": "owned"}))
        self.init()
        self.assertTrue((self.project / "components/ui/PresetTheme.qml").exists())
        config = json.loads(path.read_text())
        self.assertEqual(config["notes"], "owned")
        config["componentsDir"] = "elsewhere"
        path.write_text(json.dumps(config))
        before = self.snapshot()
        self.cli("preset", "apply", self.other, success=False)
        self.assertEqual(before, self.snapshot())
        self.assertFalse((self.project / "elsewhere").exists())

    def test_symlinks_and_malformed_records_rejected(self):
        self.init()
        target = self.project / "ui/PresetTheme.qml"
        target.unlink()
        outside = Path(self.temporary.name) / "outside.qml"
        target.symlink_to(outside)
        self.cli("preset", "apply", self.other, success=False)
        self.assertFalse(outside.exists())
        target.unlink()
        path = self.project / "quickui.json"
        config = json.loads(path.read_text())
        for record in ({}, dict(config["preset"], schemaVersion=True), dict(config["preset"], path="../outside.qml"),
                       dict(config["preset"], sha256="wrong"), dict(config["preset"], code=self.other)):
            path.write_text(json.dumps(dict(config, preset=record)))
            before = self.snapshot()
            self.cli("preset", "apply", self.other, success=False)
            self.assertEqual(before, self.snapshot())

    def test_commit_rolls_back_written_files_after_failure(self):
        cli = load_cli()
        self.init()
        path = self.project / "ui/PresetTheme.qml"
        before = self.snapshot()
        created = self.project / "nested/new.qml"
        planned = [(path, b"replacement", path.read_bytes()), (created, b"new", None)]
        with patch.object(cli.os, "link", side_effect=OSError("injected disk failure")):
            with self.assertRaisesRegex(OSError, "injected"):
                cli.commit_plan(self.project, planned)
        self.assertEqual({p: v[0] for p, v in before.items()}, {p: v[0] for p, v in self.snapshot().items()})
        self.assertFalse(created.parent.exists())
        self.assertEqual(list(self.project.rglob(".quickui-*")), [])


if __name__ == "__main__":
    unittest.main()
