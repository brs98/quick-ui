#!/usr/bin/env python3
"""Install a self-contained QuickUI snapshot without changing consumer projects."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import stat
import sys
import tempfile

SOURCE = Path(__file__).resolve().parent.parent
APP = "share/quick-ui"
MANIFEST = "share/quick-ui-install.json"
TARGETS = (APP, "bin/quickui", "bin/quickbook",
           "share/applications/quickbook.desktop",
           "share/icons/hicolor/scalable/apps/quickbook.svg")
FILES = ("quickui", "quickbook", "shell.qml", "registry.json", "LICENSE",
         "THIRD_PARTY_NOTICES.md", "README.md")
DIRECTORIES = ("app", "registry", "integrations", "stories", "examples",
               "templates", "presets", "docs", "scripts", "assets")


class InstallError(Exception):
    pass


def checked(prefix, relative=""):
    path = prefix / relative
    for item in list(reversed(path.parents)) + [path]:
        if item.is_symlink():
            raise InstallError("Refusing symlink: {}".format(item))
        if item != path and item.exists() and not item.is_dir():
            raise InstallError("Expected directory: {}".format(item))
    return path


def fingerprint(path):
    return {"sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "mode": stat.S_IMODE(path.stat().st_mode)}


def entries(prefix, targets):
    result = {}
    for relative in targets:
        path = checked(prefix, relative)
        if path.is_dir():
            for item in sorted(path.rglob("*")):
                checked(prefix, str(item.relative_to(prefix)))
                if item.is_file():
                    result[str(item.relative_to(prefix))] = fingerprint(item)
                elif not item.is_dir():
                    raise InstallError("Unsupported installed file: {}".format(item))
        elif path.is_file():
            result[relative] = fingerprint(path)
        else:
            raise InstallError("Missing installed file: {}".format(path))
    return result


def previous_install(prefix):
    manifest = checked(prefix, MANIFEST)
    if not manifest.exists():
        for relative in TARGETS:
            if checked(prefix, relative).exists():
                raise InstallError("Unowned destination exists: {}".format(prefix / relative))
        return None
    try:
        previous = json.loads(manifest.read_text())
    except (ValueError, OSError) as error:
        raise InstallError("Cannot read installation manifest: {}".format(error))
    if (not isinstance(previous, dict) or previous.get("schemaVersion") != 1
            or previous.get("targets") != list(TARGETS)
            or not isinstance(previous.get("files"), dict)):
        raise InstallError("Invalid QuickUI installation manifest")
    actual = entries(prefix, TARGETS)
    if actual != previous["files"]:
        changed = sorted(key for key in set(actual) | set(previous["files"])
                         if actual.get(key) != previous["files"].get(key))
        raise InstallError("Installed files changed; preserve or restore them before updating: "
                           + ", ".join(changed))
    return previous


def source_files(source):
    paths = [source / name for name in FILES]
    paths.extend(sorted(source.glob("*.py")))
    if (source / "VERSION").exists():
        paths.append(source / "VERSION")
    for directory in DIRECTORIES:
        base = checked(source, directory)
        if not base.is_dir():
            raise InstallError("Incomplete source snapshot: missing {}".format(base))
        for path in sorted(base.rglob("*")):
            parts = path.relative_to(base).parts
            if any(part.startswith(".") or part == "__pycache__" for part in parts):
                continue
            if path.suffix in (".pyc", ".pyo"):
                continue
            if path.is_symlink():
                raise InstallError("Refusing source symlink: {}".format(path))
            if path.is_file():
                paths.append(path)
    for path in paths:
        checked(source, str(path.relative_to(source)))
        if not path.is_file():
            raise InstallError("Incomplete source snapshot: missing {}".format(path))
    return paths


def exec_quote(value):
    # Desktop Entry string escaping is processed before Exec argument quoting.
    return '"' + value.replace("\\", "\\\\\\\\").replace('"', '\\\\"').replace(
        "$", "\\\\$").replace("`", "\\\\`").replace("%", "%%") + '"'


def write(path, text, executable=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    path.chmod(0o755 if executable else 0o644)


def stage_snapshot(stage, source, prefix, paths):
    for path in paths:
        target = stage / APP / path.relative_to(source)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(str(path), str(target))
        target.chmod(0o755 if os.access(str(path), os.X_OK) else 0o644)
    installed = prefix / APP
    write(stage / "bin/quickui", "#!/bin/sh\nexec python3 -B {} \"$@\"\n".format(
        shlex.quote(str(installed / "quickui"))), True)
    write(stage / "bin/quickbook", "#!/bin/sh\nexec bash {} \"$@\"\n".format(
        shlex.quote(str(installed / "quickbook"))), True)
    write(stage / "share/applications/quickbook.desktop",
          "[Desktop Entry]\nType=Application\nName=Quickbook\n"
          "Comment=Explore QuickUI components and design Quickshell themes\n"
          "Exec=/bin/sh {}\nIcon=quickbook\nTerminal=false\nCategories=Development;GUIDesigner;\n"
          "Keywords=QuickUI;Quickshell;QML;Themes;\n".format(exec_quote(str(prefix / "bin/quickbook"))))
    icon = stage / TARGETS[-1]
    icon.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(str(source / "assets/quickbook.svg"), str(icon))
    icon.chmod(0o644)
    version_path = source / "VERSION"
    version = version_path.read_text().strip() if version_path.exists() else "development"
    manifest = {"schemaVersion": 1, "version": version,
                "targets": list(TARGETS), "files": entries(stage, TARGETS)}
    write(stage / MANIFEST, json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    return manifest


def transact(prefix, stage, uninstall=False):
    """Stage fully, then replace targets; rollback every completed rename on failure."""
    backup = stage / ".backup"
    backup.mkdir()
    moved, placed = [], []
    try:
        for relative in TARGETS + (MANIFEST,):
            target = checked(prefix, relative)
            target.parent.mkdir(parents=True, exist_ok=True)
            if target.exists():
                saved = backup / relative
                saved.parent.mkdir(parents=True, exist_ok=True)
                os.replace(str(target), str(saved))
                moved.append(relative)
            if not uninstall:
                os.replace(str(stage / relative), str(target))
                placed.append(relative)
    except BaseException:
        for relative in reversed(placed):
            target = prefix / relative
            if target.is_dir():
                shutil.rmtree(str(target))
            else:
                target.unlink()
        for relative in reversed(moved):
            os.replace(str(backup / relative), str(prefix / relative))
        raise


def install(source, prefix, dry_run=False, uninstall=False):
    source = Path(os.path.abspath(str(source)))
    prefix = Path(os.path.abspath(os.path.expanduser(str(prefix))))
    if any(ord(char) < 32 for char in str(prefix)):
        raise InstallError("Installation prefix must not contain control characters")
    checked(prefix)
    for relative in TARGETS + (MANIFEST,):
        checked(prefix, relative)
    previous = previous_install(prefix)
    if uninstall and previous is None:
        raise InstallError("No managed QuickUI installation exists at {}".format(prefix))
    paths = [] if uninstall else source_files(source)
    action = "Uninstall" if uninstall else "Update" if previous else "Install"
    if dry_run:
        print("Would {} QuickUI at {} (no files changed)".format(action.lower(), prefix))
        return
    prefix.mkdir(parents=True, exist_ok=True)
    lock = checked(prefix, ".quick-ui-install.lock")
    try:
        lock.mkdir()
    except FileExistsError:
        raise InstallError("Another installer may be running: {}".format(lock))
    try:
        previous = previous_install(prefix)
        with tempfile.TemporaryDirectory(prefix=".quick-ui-stage-", dir=str(prefix)) as directory:
            stage = Path(directory)
            if not uninstall:
                desired = stage_snapshot(stage, source, prefix, paths)
                if previous == desired:
                    print("QuickUI is already current at {}".format(prefix))
                    return
            transact(prefix, stage, uninstall)
    finally:
        lock.rmdir()
    print("{} QuickUI at {}".format("Uninstalled" if uninstall else "Installed", prefix))
    if not uninstall:
        print("Open {} or the Quickbook application launcher.".format(prefix / "bin/quickbook"))
        print("CLI: {} (add {} to PATH if needed).".format(prefix / "bin/quickui", prefix / "bin"))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefix", default="~/.local", help="installation prefix (default: ~/.local)")
    parser.add_argument("--dry-run", action="store_true", help="validate and show intent without writing")
    parser.add_argument("--uninstall", action="store_true", help="remove unmodified managed installation only")
    arguments = parser.parse_args()
    try:
        install(SOURCE, arguments.prefix, arguments.dry_run, arguments.uninstall)
    except (InstallError, OSError) as error:
        print("QuickUI installation failed: {}".format(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
