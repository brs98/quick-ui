#!/usr/bin/env python3
"""Generate Qt JS preset catalog/codec from the versioned sources."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    catalog = json.loads((ROOT / "presets/catalog.json").read_text())
    files = {
        ROOT / "app/PresetCatalog.js": "// Generated from presets/catalog.json; do not edit.\n.pragma library\nvar catalog = " + json.dumps(catalog, indent=2) + ";\n",
        ROOT / "app/PresetCodec.js": (ROOT / "presets/codec.js.in").read_text(),
    }
    for path, content in files.items():
        if args.check:
            if not path.exists() or path.read_text() != content:
                raise SystemExit("Stale generated preset file: " + str(path.relative_to(ROOT)))
        else:
            path.write_text(content)


if __name__ == "__main__":
    main()
