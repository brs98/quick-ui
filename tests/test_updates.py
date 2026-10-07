"""Reviewed source upgrades against synthetic bundled revisions and local edits."""
import hashlib
import contextlib
import io
import importlib.machinery
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader('update_cli', str(ROOT / 'quickui'))
spec = importlib.util.spec_from_loader(loader.name, loader)
cli = importlib.util.module_from_spec(spec)
loader.exec_module(cli)
BASE = b'// first\n// middle\n// last\n'


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bundle = self.root / 'bundle'
        self.bundle.mkdir()
        shutil.copy2(ROOT / 'quickui', self.bundle / 'quickui')
        self.sources = self.bundle / 'registry/quickui'
        self.sources.mkdir(parents=True)
        self.entries = {'theme': {'file': 'Theme.qml', 'dependencies': []},
                        'button': {'file': 'Button.qml', 'dependencies': ['theme']},
                        'slider': {'file': 'Slider.qml', 'dependencies': ['theme']}}
        self.registry()
        for row in self.entries.values():
            (self.sources / row['file']).write_bytes(BASE)
        self.project = self.root / 'project'
        self.project.mkdir()
        self.run_cli('init')
        self.run_cli('add', 'button', 'slider')

    def registry(self):
        (self.bundle / 'registry.json').write_text(json.dumps({'schemaVersion': 1, 'components': self.entries}))

    def run_cli(self, *args, success=True):
        result = subprocess.run([sys.executable, str(self.bundle / 'quickui'), *args, '--cwd', str(self.project)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)
        self.assertNotIn('Traceback', result.stderr)
        return result

    def snapshot(self):
        return {str(path.relative_to(self.project)): (path.read_bytes(), path.stat().st_mtime_ns)
                for path in self.project.rglob('*') if path.is_file()}

    def config(self):
        return json.loads((self.project / 'quickui.json').read_text())

    def base(self, value=BASE):
        return self.project / '.quickui/bases' / hashlib.sha256(value).hexdigest()

    def test_pristine_snapshots_safe_update_metadata_and_noop(self):
        self.assertEqual(self.base().read_bytes(), BASE)
        config = self.config(); config['custom'] = {'kept': True}; config['installed']['button']['note'] = 'owned'
        (self.project / 'quickui.json').write_text(json.dumps(config))
        updated = BASE.replace(b'middle', b'upstream')
        (self.sources / 'Button.qml').write_bytes(updated)
        before = self.snapshot()
        self.assertIn('update available', self.run_cli('diff', 'button').stdout)
        self.run_cli('update', 'button', '--dry-run')
        self.assertEqual(before, self.snapshot())
        self.run_cli('update', 'button')
        self.assertEqual((self.project / 'ui/Button.qml').read_bytes(), updated)
        self.assertEqual(self.base(updated).read_bytes(), updated)
        self.assertEqual(self.config()['custom'], config['custom'])
        self.assertEqual(self.config()['installed']['button']['note'], 'owned')
        after = self.snapshot(); self.run_cli('update'); self.assertEqual(after, self.snapshot())

    def test_customized_dependency_kept_when_upstream_unchanged(self):
        custom = BASE + b'// local theme\n'
        (self.project / 'ui/Theme.qml').write_bytes(custom)
        (self.sources / 'Button.qml').write_bytes(BASE + b'// upstream button\n')
        self.run_cli('update', 'button')
        self.assertEqual((self.project / 'ui/Theme.qml').read_bytes(), custom)
        self.assertEqual(self.config()['installed']['theme']['sha256'], hashlib.sha256(BASE).hexdigest())

    def test_disjoint_merge_is_review_only_and_conflicted_batch_never_writes(self):
        (self.project / 'ui/Button.qml').write_bytes(BASE.replace(b'first', b'local'))
        (self.sources / 'Button.qml').write_bytes(BASE.replace(b'last', b'upstream'))
        (self.sources / 'Slider.qml').write_bytes(BASE + b'// upgrade\n')
        before = self.snapshot()
        result = self.run_cli('update', success=False)
        self.assertIn('no files changed', result.stderr)
        self.assertEqual(before, self.snapshot())
        self.run_cli('diff', 'button', '--proposals', 'review', '--dry-run')
        self.assertEqual(before, self.snapshot())
        self.run_cli('diff', 'button', '--proposals', 'review')
        self.assertEqual((self.project / 'review/button/merged.qml').read_bytes(), BASE.replace(b'first', b'local').replace(b'last', b'upstream'))
        report = json.loads((self.project / 'review/review.json').read_text())
        self.assertEqual(report['files'][0]['conflicts'], 0)
        self.assertEqual({key: value for key, value in self.snapshot().items() if not key.startswith('review/')}, before)
        self.run_cli('diff', '--proposals', 'review', success=False)

    def test_reviewed_keep_customized_updates_only_pristine_files(self):
        custom=BASE + b'// user customization\n'
        (self.project / 'ui/Theme.qml').write_bytes(custom)
        (self.sources / 'Theme.qml').write_bytes(BASE + b'// upstream theme\n')
        (self.sources / 'Button.qml').write_bytes(BASE + b'// upstream button\n')
        original_record=self.config()['installed']['theme']
        before=self.snapshot()
        self.run_cli('update','button','--keep-customized','--dry-run')
        self.assertEqual(before,self.snapshot())
        self.run_cli('update','button','--keep-customized')
        self.assertEqual((self.project / 'ui/Theme.qml').read_bytes(),custom)
        self.assertEqual(self.config()['installed']['theme'],original_record)
        self.assertEqual((self.project / 'ui/Button.qml').read_bytes(),BASE+b'// upstream button\n')

    def test_conflicts_remain_in_proposal_hunks_not_live_sources(self):
        local, remote = BASE.replace(b'middle', b'local'), BASE.replace(b'middle', b'remote')
        (self.project / 'ui/Button.qml').write_bytes(local)
        (self.sources / 'Button.qml').write_bytes(remote)
        self.run_cli('diff', 'button', '--proposals', 'review')
        merged = (self.project / 'review/button/merged.qml').read_bytes()
        self.assertTrue(merged.startswith(b'// first\n<<<<<<< local\n'))
        self.assertTrue(merged.endswith(b'>>>>>>> bundled\n// last\n'))
        self.assertIn(b'||||||| installed base\n// middle\n', merged)
        self.assertEqual((self.project / 'ui/Button.qml').read_bytes(), local)
        report = json.loads((self.project / 'review/review.json').read_text())
        self.assertEqual(report['files'][0]['conflicts'], 1)

    def test_legacy_no_base_never_infers_edited_bytes(self):
        shutil.rmtree(self.project / '.quickui')
        local = BASE + b'// mine\n'; (self.project / 'ui/Button.qml').write_bytes(local)
        (self.sources / 'Button.qml').write_bytes(BASE + b'// upstream\n')
        self.run_cli('diff', 'button', '--proposals', 'review')
        self.assertFalse((self.project / 'review/button/base.qml').exists())
        self.assertFalse((self.project / 'review/button/merged.qml').exists())
        self.assertFalse(self.base(local).exists())
        self.run_cli('update', 'button', success=False)
        (self.sources / 'Slider.qml').write_bytes(BASE + b'// safe\n')
        self.run_cli('update', 'slider')
        self.assertEqual((self.project / 'ui/Slider.qml').read_bytes(), BASE + b'// safe\n')

    def test_new_dependencies_and_missing_owned_sources(self):
        self.entries['helper'] = {'file': 'Helper.qml', 'dependencies': []}
        self.entries['button']['dependencies'].append('helper'); self.registry()
        (self.sources / 'Helper.qml').write_bytes(b'// helper\n')
        (self.project / 'ui/Button.qml').unlink()
        self.run_cli('update', 'button')
        self.assertEqual((self.project / 'ui/Button.qml').read_bytes(), BASE)
        self.assertEqual((self.project / 'ui/Helper.qml').read_bytes(), b'// helper\n')

    def test_unowned_dependency_blocks_entire_batch(self):
        config = self.config(); del config['installed']['slider']
        (self.project / 'quickui.json').write_text(json.dumps(config))
        (self.sources / 'Button.qml').write_bytes(BASE + b'// changed\n')
        before = self.snapshot()
        self.run_cli('update', 'button', 'slider', success=False)
        self.assertEqual(before, self.snapshot())

    def test_unsafe_proposal_paths_and_symlinks(self):
        for path in ('../outside', '/tmp/review', 'ui/review', 'ui', '.quickui/review', 'quickui.json'):
            self.run_cli('diff', '--proposals', path, success=False)
        outside = self.root / 'outside'; outside.mkdir()
        (self.project / 'review').symlink_to(outside, target_is_directory=True)
        self.run_cli('diff', '--proposals', 'review/nested', success=False)
        self.assertEqual(list(outside.iterdir()), [])

    def test_base_corruption_symlink_and_path_changes_refused(self):
        self.base().write_bytes(b'corrupted')
        before = self.snapshot(); self.run_cli('update', success=False); self.assertEqual(before,self.snapshot())
        self.base().unlink(); self.base().symlink_to(self.root / 'missing')
        self.run_cli('diff', success=False)
        self.base().unlink(); self.base().write_bytes(BASE)
        config = self.config(); config['componentsDir'] = 'other'
        (self.project / 'quickui.json').write_text(json.dumps(config))
        self.run_cli('update', success=False)
        self.assertFalse((self.project / 'other').exists())

    def test_snapshot_directory_cannot_be_a_component_destination(self):
        config=self.config(); config['componentsDir']='.quickui/bases'
        (self.project / 'quickui.json').write_text(json.dumps(config))
        before=self.snapshot()
        self.run_cli('update',success=False)
        self.run_cli('init',success=False)
        self.assertEqual(before,self.snapshot())

    def test_source_and_destination_symlinks_refused(self):
        for path in (self.sources / 'Button.qml', self.project / 'ui/Button.qml'):
            content = path.read_bytes(); path.unlink(); path.symlink_to(self.root / 'missing')
            self.run_cli('update', success=False)
            path.unlink(); path.write_bytes(content)

    def test_transaction_rolls_back_source_bases_metadata_and_directories(self):
        (self.sources / 'Button.qml').write_bytes(BASE + b'// new button\n')
        (self.sources / 'Slider.qml').write_bytes(BASE + b'// new slider\n')
        before = {key:value[0] for key,value in self.snapshot().items()}
        replace = cli.os.replace
        def fail_second_source(source, target):
            if Path(target).name == 'Slider.qml':
                raise OSError('synthetic disk error')
            return replace(source, target)
        args = type('Args', (), dict(cwd=str(self.project), command='update', components=[], dry_run=False))()
        with patch.object(cli, 'ROOT', self.bundle), patch.object(cli.os, 'replace', side_effect=fail_second_source):
            with self.assertRaisesRegex(OSError, 'synthetic'):
                cli.review_sources(self.entries,args)
        self.assertEqual(before,{key:value[0] for key,value in self.snapshot().items()})
        self.assertEqual(list(self.project.rglob('.quickui-*')),[])

    def test_rollback_double_failure_retains_atomic_original_backup(self):
        first=self.project / 'ui/Button.qml'; second=self.project / 'ui/Slider.qml'
        replace=cli.os.replace
        def fail_commit_and_recovery(source,target):
            if Path(target)==second or Path(source).name.startswith('.quickui-backup-'):
                raise OSError('synthetic unavailable filesystem')
            return replace(source,target)
        output=io.StringIO()
        with patch.object(cli.os,'replace',side_effect=fail_commit_and_recovery), contextlib.redirect_stderr(output):
            with self.assertRaisesRegex(OSError,'synthetic'):
                cli.commit_plan(self.project,[(first,b'updated first',BASE),(second,b'updated second',BASE)])
        self.assertEqual(first.read_bytes(),b'updated first')
        self.assertEqual(second.read_bytes(),BASE)
        backups=list(self.project.rglob('.quickui-backup-*'))
        self.assertEqual(len(backups),1)
        self.assertEqual(backups[0].read_bytes(),BASE)
        self.assertIn(str(backups[0]),output.getvalue())
        self.assertIn('rollback incomplete',output.getvalue())

    def test_keyboard_interrupt_rolls_back_without_truncating_original(self):
        first=self.project / 'ui/Button.qml'; second=self.project / 'ui/Slider.qml'
        replace=cli.os.replace
        def interrupt_second(source,target):
            if Path(target)==second:
                raise KeyboardInterrupt()
            return replace(source,target)
        before=self.snapshot()
        with patch.object(cli.os,'replace',side_effect=interrupt_second), patch.object(Path,'write_bytes',side_effect=AssertionError('rollback must use staged bytes')):
            with self.assertRaises(KeyboardInterrupt):
                cli.commit_plan(self.project,[(first,b'updated first',BASE),(second,b'updated second',BASE)])
        self.assertEqual(self.snapshot(),before)
        self.assertEqual(list(self.project.rglob('.quickui-*')),[])

    def test_new_install_rollback_removes_sources_cache_and_metadata(self):
        fresh=self.root / 'fresh'; fresh.mkdir()
        link=cli.os.link
        def fail_cache(source,target):
            if '.quickui/bases' in str(target):
                raise OSError('synthetic cache write failure')
            return link(source,target)
        args=type('Args',(),dict(cwd=str(fresh),command='init',dry_run=False))()
        with patch.object(cli,'ROOT',self.bundle), patch.object(cli.os,'link',side_effect=fail_cache):
            with self.assertRaisesRegex(OSError,'synthetic'):
                cli.install(self.entries,args)
        self.assertEqual(list(fresh.iterdir()),[])

    def test_corrupt_base_blocks_install_before_new_source_creation(self):
        self.base().write_bytes(b'corrupt')
        (self.project / 'ui/Slider.qml').unlink()
        before=self.snapshot()
        self.run_cli('add','slider',success=False)
        self.assertEqual(before,self.snapshot())

    def test_optional_generated_and_integration_managed_sources_untouched(self):
        config = self.config(); config['omarchy'] = {'files': {'ui/Button.qml': hashlib.sha256(BASE).hexdigest()}}
        (self.project / 'quickui.json').write_text(json.dumps(config))
        (self.project / 'ui/PresetTheme.qml').write_text('// owned generated')
        (self.sources / 'Button.qml').write_bytes(BASE + b'// new\n')
        before = self.snapshot(); self.run_cli('update', 'button'); self.assertEqual(before,self.snapshot())
        self.assertIn('integration-managed', self.run_cli('diff','button').stdout)


class MergeTests(unittest.TestCase):
    def test_identities_and_newline_preservation(self):
        for value in (b'', b'a', b'a\r\nb\r\n'):
            self.assertEqual(cli.merge_sources(value,value,value),(value,0))
            self.assertEqual(cli.merge_sources(b'',value,value),(value,0))
            self.assertEqual(cli.merge_sources(value,value,b''),(b'',0))

    def test_disjoint_identical_and_overlapping_insertions(self):
        self.assertEqual(cli.merge_sources(b'a\nb\n',b'x\na\nb\n',b'a\nb\ny\n'),(b'x\na\nb\ny\n',0))
        self.assertEqual(cli.merge_sources(b'a\n',b'x\na\n',b'x\na\n'),(b'x\na\n',0))
        merged,conflicts=cli.merge_sources(b'a\n',b'x\na\n',b'y\na\n')
        self.assertEqual(conflicts,1); self.assertIn(b'<<<<<<< local',merged)


if __name__ == '__main__':
    unittest.main()
