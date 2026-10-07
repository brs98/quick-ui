import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('session_store', ROOT / 'app/session_store.py')
store = importlib.util.module_from_spec(spec)
spec.loader.exec_module(store)


def state():
    return {'schemaVersion': 1, 'session': {'design': {'code': 'q1-6bi', 'locks': {'radius': True}, 'dark': False,
        'omarchy': True, 'follow': {'colors': True, 'typography': False, 'radius': True, 'spacing': False}, 'radiusMultiplier': 0.75},
        'mode': 'create', 'story': 'button', 'preset': 0, 'dark': True, 'grid': False, 'viewportWidth': 640, 'viewportHeight': 700}, 'designs': []}


class SessionStoreTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.environment = patch.dict(os.environ, {'QUICKBOOK_STATE_DIR': self.temp.name})
        self.environment.start()
        self.addCleanup(self.environment.stop)
        self.path = Path(self.temp.name) / 'state.json'

    def test_atomic_roundtrip_and_conflict(self):
        self.assertIsNone(store.execute({'action': 'load'})['data'])
        data = state()
        data['designs'] = [{'name': 'Ocean', 'design': data['session']['design']}]
        first = store.execute({'action': 'save', 'revision': '', 'data': data})
        self.assertEqual(store.execute({'action': 'load'})['data'], data)
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)
        original = self.path.read_bytes()
        with self.assertRaisesRegex(ValueError, 'another Quickbook'):
            store.execute({'action': 'save', 'revision': '', 'data': state()})
        self.assertEqual(self.path.read_bytes(), original)
        store.execute({'action': 'save', 'revision': first['revision'], 'data': state()})
        self.assertEqual(list(Path(self.temp.name).glob('.state-*')), [])

    def test_malformed_preserved_and_recovered(self):
        self.path.write_text('{broken')
        with self.assertRaises(ValueError): store.execute({'action': 'load'})
        with self.assertRaises(ValueError): store.execute({'action': 'save', 'revision': store.revision(b'{broken'), 'data': state()})
        self.assertEqual(self.path.read_text(), '{broken')
        result = store.execute({'action': 'recover'})
        self.assertEqual(Path(result['backup']).read_text(), '{broken')
        self.assertFalse(self.path.exists())
        store.execute({'action': 'save', 'revision': '', 'data': state()})

    def test_rejects_schema_bounds_and_unknown_values(self):
        edits = [lambda d: d.update(schemaVersion=2), lambda d: d['session'].update(secret='ignored?'),
            lambda d: d['session']['design'].update(code='q9-123'), lambda d: d['session']['design'].update(radiusMultiplier=float('nan')),
            lambda d: d['session']['design'].update(locks={'bogus': True}), lambda d: d['session'].update(viewportWidth=-2)]
        for edit in edits:
            with self.subTest(edit=edit):
                data = state(); edit(data)
                with self.assertRaises((ValueError, TypeError)): store.validate(data)
        data = state(); data['designs'] = [{'name': 'Ocean', 'design': data['session']['design']}, {'name': 'ocean', 'design': data['session']['design']}]
        with self.assertRaisesRegex(ValueError, 'Duplicate'): store.validate(data)
        self.path.write_bytes(b' ' * (store.LIMIT + 1))
        with self.assertRaisesRegex(ValueError, '256 KiB'): store.execute({'action': 'load'})
        store.execute({'action': 'recover'})
