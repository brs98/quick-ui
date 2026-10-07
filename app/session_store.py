#!/usr/bin/env python3
"""Private local Quickbook state; validated, atomic and conflict checked."""
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
import time

sys.dont_write_bytecode = True
LIMIT = 262144

def validate(value):
    if not isinstance(value, dict) or set(value) != {'schemaVersion', 'session', 'designs'} or type(value['schemaVersion']) is not int or value['schemaVersion'] != 1:
        raise ValueError('Unsupported Quickbook state schema')
    session = value['session']
    if not isinstance(session, dict) or set(session) != {'design', 'mode', 'story', 'preset', 'dark', 'grid', 'viewportWidth', 'viewportHeight'}:
        raise ValueError('Invalid session')
    design(session['design'])
    if session['mode'] not in ('create', 'components') or not isinstance(session['story'], str) or len(session['story']) > 100:
        raise ValueError('Invalid session selection')
    for key in ('dark', 'grid'):
        if type(session[key]) is not bool: raise ValueError('Invalid session flag')
    for key, maximum in (('preset', 1000), ('viewportWidth', 10000), ('viewportHeight', 10000)):
        if type(session[key]) is not int or not 0 <= session[key] <= maximum: raise ValueError('Invalid canvas setting')
    if not isinstance(value['designs'], list) or len(value['designs']) > 100: raise ValueError('At most 100 saved designs are supported')
    names = set()
    for row in value['designs']:
        if not isinstance(row, dict) or set(row) != {'name', 'design'}: raise ValueError('Invalid saved design')
        name = row['name']
        if not isinstance(name, str) or not name.strip() or name != name.strip() or len(name) > 80 or any(ord(c) < 32 for c in name): raise ValueError('Invalid design name')
        if name.lower() in names: raise ValueError('Duplicate design names')
        names.add(name.lower())
        design(row['design'])
    return value

def design(value):
    if not isinstance(value, dict) or set(value) != {'code', 'locks', 'dark', 'omarchy', 'follow', 'radiusMultiplier'}: raise ValueError('Invalid design')
    # Import the immutable shared codec instead of redefining preset semantics.
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    import presetlib
    presetlib.decode(value['code'])
    if not isinstance(value['locks'], dict) or any(k not in presetlib.defaults() or type(v) is not bool for k, v in value['locks'].items()): raise ValueError('Invalid locks')
    if any(type(value[k]) is not bool for k in ('dark', 'omarchy')): raise ValueError('Invalid design flags')
    if not isinstance(value['follow'], dict) or set(value['follow']) != {'colors', 'typography', 'radius', 'spacing'} or any(type(v) is not bool for v in value['follow'].values()): raise ValueError('Invalid follow settings')
    radius = value['radiusMultiplier']
    if type(radius) not in (int, float) or not 0 <= radius <= 2: raise ValueError('Invalid radius multiplier')

def location():
    override = os.environ.get('QUICKBOOK_STATE_DIR')
    return Path(override) if override else Path(os.environ.get('XDG_STATE_HOME') or Path.home() / '.local/state') / 'quickbook'

def revision(raw): return hashlib.sha256(raw).hexdigest() if raw is not None else ''

def read(path):
    if not path.exists(): return None
    with path.open('rb') as stream:
        raw = stream.read(LIMIT + 1)
    if len(raw) > LIMIT: raise ValueError('State exceeds 256 KiB; original file preserved')
    return raw

def execute(request):
    import fcntl
    directory = location()
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    path = directory / 'state.json'
    with (directory / '.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if request['action'] == 'recover':
            backup = ''
            if path.exists():
                backup = str(directory / ('state.backup-' + str(time.time_ns()) + '.json'))
                path.rename(backup)
            return {'ok': True, 'revision': '', 'data': None, 'backup': backup}
        raw = read(path)
        if request['action'] == 'load':
            return {'ok': True, 'revision': revision(raw), 'data': validate(json.loads(raw)) if raw is not None else None}
        if request['action'] != 'save': raise ValueError('Unknown state action')
        if revision(raw) != request.get('revision'): raise ValueError('State changed in another Quickbook window. Reload Quickbook before saving.')
        if raw is not None: validate(json.loads(raw))
        payload = (json.dumps(validate(request['data']), ensure_ascii=False, indent=2, allow_nan=False) + '\n').encode()
        if len(payload) > LIMIT: raise ValueError('State exceeds 256 KiB')
        descriptor, temporary = tempfile.mkstemp(prefix='.state-', dir=directory)
        try:
            with os.fdopen(descriptor, 'wb') as stream:
                stream.write(payload)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, path)
            directory_fd = os.open(directory, os.O_DIRECTORY)
            try: os.fsync(directory_fd)
            finally: os.close(directory_fd)
        finally:
            if os.path.exists(temporary): os.unlink(temporary)
        return {'ok': True, 'revision': revision(payload)}

if __name__ == '__main__':
    try:
        raw = sys.stdin.buffer.readline(LIMIT * 2 + 1)
        if len(raw) > LIMIT * 2: raise ValueError('State request too large')
        result = execute(json.loads(raw))
    except Exception as error:
        result = {'ok': False, 'error': str(error)}
    print(json.dumps(result))
