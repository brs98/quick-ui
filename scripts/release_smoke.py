#!/usr/bin/env python3
"""Verify a packaged release installs and runs without a Git checkout."""
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    version = (ROOT / 'VERSION').read_text().strip()
    archive = ROOT / 'artifacts/release' / ('quick-ui-' + version + '.tar.gz')
    with tempfile.TemporaryDirectory(prefix='quickui-release-') as directory:
        temporary = Path(directory)
        # package.py already rejects links; still validate before extraction.
        with tarfile.open(str(archive)) as stream:
            for member in stream.getmembers():
                assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
                assert member.isfile() or member.isdir()
            stream.extractall(str(temporary))
        source = temporary / ('quick-ui-' + version)
        prefix = temporary / 'installed tools'
        project = temporary / 'consumer'; project.mkdir()
        def run(*args):
            return subprocess.run([str(arg) for arg in args], cwd=str(temporary), check=True, capture_output=True, text=True).stdout
        run('python3', source / 'scripts/install.py', '--prefix', prefix)
        shutil.rmtree(str(source))
        cli = prefix / 'bin/quickui'
        run(cli, 'init', '--cwd', project)
        run(cli, 'add', 'button', '--cwd', project)
        assert (project / 'ui/Button.qml').is_file()
        assert 'button' in run(cli, 'list')
        run(cli, 'diff', '--cwd', project)
        run(cli, 'update', '--cwd', project, '--dry-run')
        # Imports and normal CLI use must not create files in managed installation.
        installer = prefix / 'share/quick-ui/scripts/install.py'
        assert 'already current' in run('python3', installer, '--prefix', prefix)
        run('python3', installer, '--prefix', prefix, '--uninstall')
        assert (project / 'ui/Button.qml').is_file() and not cli.exists()
    print('PASS extracted release install, independent CLI, clean managed snapshot, uninstall preserving consumer')


if __name__ == '__main__':
    main()
