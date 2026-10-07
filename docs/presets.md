# QuickUI presets

Quickbook's **Create** view previews real QuickUI controls with a shared theme. Choose a palette, accent, font family, density, radius, border, selection treatment, and motion preference. Lock choices before shuffling; locks constrain shuffle, while direct edits and Reset remain available. Color source starts locked so a shuffle keeps the preview self-contained. Undo restores previous choices. Copy a preset code or JSON to retain your work across restarts; the editor's history is held in memory.

The preview's light/dark switch changes the preview only. Light and dark colors are both included in each preset, so a consumer can change its Theme's `dark` property at runtime. Generic font families resolve to installed fonts on the consumer's machine.

## Share and install

`q1-6bi` is the default preset. A preset code describes all nine choices; it is not a random seed, an upload, or a server-side ID. Opening the same code reproduces the same token definitions without network access.

```sh
# Inspect or export a shared preset.
./quickui preset inspect q1-6bi
./quickui preset inspect q1-6bi --json
./quickui preset export q1-6bi > preset.json
./quickui preset encode preset.json

# Initialize a new consumer project with a preset.
./quickui init --preset q1-6bi --cwd /path/to/project
./quickui add button text-field switch --cwd /path/to/project

# Preview and apply another preset in an initialized project.
./quickui preset apply q1-6j6 --cwd /path/to/project --dry-run
./quickui preset apply q1-6j6 --cwd /path/to/project
```

The consumer owns copied QML sources. Initialization copies `Theme.qml` when it is absent and generates a separate `PresetTheme.qml` beside it. Applying a preset updates the generated sibling and its origin record in `quickui.json`. Existing `Theme.qml` and component files remain byte-for-byte unchanged, including local edits. A matching reapplication is a no-op and preserves timestamps.

The CLI records the generated file's SHA-256 fingerprint. It refuses to overwrite an edited or unrelated `PresetTheme.qml`; there is no force flag. Keep or move your edited version deliberately before regenerating, or merge a new preset in a temporary project. Invalid codes, malformed metadata, unsafe paths, and expected conflicts are rejected before writes. Dry runs validate the same plan without creating files. Preset writes are staged and rolled back if a later write fails; this is not a multi-file filesystem transaction against a process or machine crash.

Bind the generated theme to your components:

```qml
import QtQuick
import "ui" as UI

Item {
    UI.PresetTheme { id: tokens; dark: true }
    UI.Button { theme: tokens; text: "Save" }
}
```

The generated theme contains explicit light/dark values and needs only its sibling `Theme.qml`. It does not import Quickbook, its codec, or its catalog. Token overrides on your copied `Theme.qml` can be superseded by the generated preset's explicit values; bind components to the theme you intend to use.

## Host colors

Choosing **Host colors** records the intent to follow a host-supplied theme. Supply a compatible QuickUI `Theme` object through `systemTheme`:

```qml
UI.Theme {
    id: hostTokens
    // Bind these tokens to your shell's theme adapter.
    accent: "#70ceff"
}
UI.PresetTheme {
    id: tokens
    systemTheme: hostTokens
}
```

All color roles then follow the host object. Font, dimensions, radius, border width, and motion still come from the preset. Without a supplied host theme, the selected palette and accent provide a standalone fallback. Quickbook uses that fallback unless a host integrates its theme. The preset does not read, change, or export the desktop's theme. The host adapter is responsible for the contrast of its supplied colors.

## JSON and compatibility

Exported JSON contains exactly a schema version, a code, and the decoded choices:

```json
{
  "schemaVersion": 1,
  "code": "q1-6bi",
  "config": {
    "colorSource": "preset",
    "palette": "neutral",
    "accent": "lavender",
    "font": "sans",
    "density": "default",
    "radius": "default",
    "border": "thin",
    "selection": "subtle",
    "motion": "normal"
  }
}
```

`preset encode` also accepts a bare complete config object. Envelope code/config disagreement, duplicate JSON keys, unknown fields, unknown choices, unsupported versions, and noncanonical codes are rejected. Quickbook's Open field accepts the compact code; use the CLI to encode JSON first.

The `q1` code uses ordered mixed-radix choice indices, encoded as lowercase base36. The v1 catalog freezes both option ordering **and token meanings**, including palette values. Changing these meanings requires a new code version and preservation of the old decoder/resolver. A new label can be reviewed separately, but the compatibility digest must never be updated merely to make a changed v1 token test pass.

`presets/catalog.json` is the source for token definitions; `presets/codec.js.in` and `presetlib.py` implement the Qt JavaScript and Python runtimes. Regenerate bundled JavaScript after source changes:

```sh
python3 scripts/generate_presets.py
python3 scripts/generate_presets.py --check
python3 -m unittest discover -s tests -p 'test_presets.py'
```

Tests cover the complete code space, frozen catalog, Python/Qt JavaScript parity, generated QML values and host binding, curated text contrast in both modes, and consumer file preservation. Contrast checks apply to the supplied text roles and backgrounds; they do not certify every composition, disabled control, host palette, or custom override.
