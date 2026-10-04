#!/usr/bin/env python3
"""Inspect QuickUI through native QAccessible (requires Qt 6 development headers and C++)."""
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent


def main():
    flags = shlex.split(subprocess.check_output(
        ["pkg-config", "--cflags", "--libs", "Qt6Quick", "Qt6Gui", "Qt6Qml"], text=True))
    with tempfile.TemporaryDirectory(prefix="quickui-accessibility-") as directory:
        binary = Path(directory) / "probe"
        subprocess.run(["c++", "-fPIC", "-pie", str(ROOT / "tests/native/accessibility.cpp"),
                        "-o", str(binary), *flags], check=True, timeout=60)
        result = subprocess.run([str(binary), str(ROOT / "tests/fixtures/accessibility.qml")],
                                env=dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software"),
                                text=True, capture_output=True, check=True, timeout=15)
        if result.stderr.strip():
            raise AssertionError(result.stderr)
        tree = json.loads(result.stdout)

        def descendants(node):
            yield node
            for child in node.get("children", []):
                yield from descendants(child)

        nodes = list(descendants(tree))

        def named(name):
            matches = [node for node in nodes if node.get("name") == name]
            assert len(matches) == 1, (name, matches)
            return matches[0]

        for name, value, minimum, maximum in [("Clamped level", 1, 0, 1), ("Invalid level", 0, 0, 1),
                                             ("Lower limit", 20, 0, 80), ("Upper limit", 80, 20, 100)]:
            node = named(name)
            assert (node["value"], node["minimum"], node["maximum"]) == (value, minimum, maximum), node
        device = named("Speakers")
        assert device["selected"] and device["selectable"], device
        assert "Press" in device["actions"], device
        cursor = [node for node in nodes if node["focused"] and "64%" in node["name"]]
        assert len(cursor) == 1 and cursor[0]["description"], cursor
        print("Native accessibility passed: bounded meter values, independent range handles, device selection, named panel cursor.")


if __name__ == "__main__":
    main()
