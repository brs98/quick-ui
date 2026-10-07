#!/usr/bin/env python3
"""Exercise real Quickshell save, close, reopen, debounce and corrupt recovery."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
DRIVER = r'''
    property int phase: 0
    function check(ok, message) {
        if (!ok) { console.error("SESSION_FAIL " + message); Qt.quit(); }
        return ok;
    }
    Timer {
        id: persistenceDriver
        interval: 80; repeat: true; running: true
        onTriggered: {
            const stage = Quickshell.env("SESSION_STAGE");
            const builder = explorer.presetBuilder;
            const store = explorer.sessionState;
            if (stage === "corrupt") {
                if (!sessionBridge.error) return;
                if (!shell.check(!store.ready, "corrupt state stays unsaved")) return;
                console.log("SESSION_CORRUPT"); Qt.quit(); return;
            }
            if (stage === "recover" && shell.phase === 0) {
                if (!sessionBridge.error) return;
                shell.phase = 1; sessionBridge.recover(); return;
            }
            if (!store.ready) return;
            if (stage === "recover") {
                if (sessionBridge.error || sessionBridge.worker.running) return;
                console.log("SESSION_OK"); persistenceDriver.stop(); explorer.Window.window.close(); return;
            }
            if (stage === "save") {
                builder.createState.setOption("accent", "ocean");
                builder.createState.toggleLock("radius"); builder.dark = false;
                builder.omarchyPreview = true; builder.radiusMultiplier = 0.75; builder.followTypography = false;
                explorer.createMode = true; explorer.explorerState.viewportWidth = 640;
                if (!shell.check(store.saveDesign("Ocean"), "save named recipe")) return;
                builder.omarchyPreview = false;
                if (!shell.check(store.saveDesign("Portable"), "save portable design")) return;
                store.loadDesign(0);
                console.log("SESSION_OK"); persistenceDriver.stop(); explorer.Window.window.close(); return;
            }
            if (stage === "restore" && shell.phase === 0) {
                if (!shell.check(explorer.createMode && builder.createState.config.accent === "ocean" && builder.createState.locks.radius
                    && builder.dark === false && builder.omarchyPreview && builder.radiusMultiplier === 0.75 && !builder.followTypography,
                    "restore live design")) return;
                if (!shell.check(store.designs.length === 2 && explorer.explorerState.viewportWidth === 640, "restore designs and canvas")) return;
                if (!shell.check(store.loadDesign(1) && !builder.omarchyPreview, "portable design exact mode")) return;
                store.renameDesign(1, "Portable renamed"); store.deleteDesign(0);
                builder.radiusMultiplier = 1.25; builder.createState.setOption("radius", "large");
                shell.phase = 1; return;
            }
            if (stage === "restore" && shell.phase === 1 && sessionBridge.saved === store.snapshot && !sessionBridge.worker.running) {
                console.log("SESSION_OK"); persistenceDriver.stop(); explorer.Window.window.close();
            }
        }
    }
    Timer { interval: 12000; running: true; onTriggered: { console.error("SESSION_FAIL timeout"); Qt.quit(); } }
'''


def main():
    with tempfile.TemporaryDirectory(prefix='quickbook-persistence-') as directory:
        temporary = Path(directory)
        config = temporary / 'app'
        shutil.copytree(ROOT, config, ignore=shutil.ignore_patterns('.git', '__pycache__', 'artifacts'))
        shell = config / 'shell.qml'
        text = shell.read_text().replace('enabled: explorer.createMode && explorer.presetBuilder.omarchyPreview', 'enabled: false'); shell.write_text(text[:text.rfind('}')] + DRIVER + '\n}\n')
        runtime = temporary / 'runtime'; runtime.mkdir(mode=0o700)
        state = temporary / 'state'
        environment = dict(os.environ, QUICKBOOK_STATE_DIR=str(state), QUICKBOOK_NO_PERSIST='0',
            XDG_RUNTIME_DIR=str(runtime), QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software', QS_NO_RELOAD_POPUP='1')
        # Host colors use synthetic absence rather than reading desktop theme settings.
        environment['XDG_CONFIG_HOME'] = str(temporary / 'config')
        for stage in ('save', 'restore', 'corrupt', 'recover'):
            if stage == 'corrupt': (state / 'state.json').write_text('{broken')
            result = subprocess.run(['quickshell', '-p', str(shell)], env=dict(environment, SESSION_STAGE=stage),
                text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20)
            if result.returncode or 'SESSION_FAIL' in result.stdout or ('SESSION_OK' not in result.stdout and 'SESSION_CORRUPT' not in result.stdout):
                raise SystemExit(result.stdout)
            errors = [line for line in result.stdout.splitlines() if ('WARN' in line or 'ERROR' in line) and not any(message in line for message in ('Failed to start IPC server', 'Module path contains invalid characters', 'This plugin does not support setting window masks'))]
            if errors: raise SystemExit('\n'.join(errors))
            if stage == 'save':
                data = json.loads((state / 'state.json').read_text()); assert len(data['designs']) == 2
            if stage == 'restore':
                data = json.loads((state / 'state.json').read_text())
                assert data['session']['design']['radiusMultiplier'] == 1.25
                assert data['designs'][0]['name'] == 'Portable renamed' and len(data['designs']) == 1
            if stage == 'corrupt': assert (state / 'state.json').read_text() == '{broken'
            if stage == 'recover':
                assert next(state.glob('state.backup-*.json')).read_text() == '{broken'
                assert json.loads((state / 'state.json').read_text())['schemaVersion'] == 1
        assert not list(config.rglob('__pycache__')), 'Persistence must not modify installed source files'
        print('PASS native session close/reopen, named portable/Omarchy designs, debounce and corrupt-state recovery')


if __name__ == '__main__': main()
