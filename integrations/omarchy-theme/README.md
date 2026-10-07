# Optional Omarchy theme integration

QuickUI and Quickbook work without Omarchy. This optional integration supplies resolved host tokens to the portable `HostTheme` component. It does not change the desktop theme or import Omarchy singletons into the component library.

Tested against Omarchy 4.0.4, Quickshell 0.3.1, and Qt 6.11.2. Omarchy-specific mappings live entirely in this optional directory.

## Design and install

In Quickbook's **Create** view, enable the Omarchy preview and choose which categories follow the host. Copy the recipe to `quickui-omarchy.json` (paste that JSON into the Open field to restore it), then install into an existing Quickshell project:

```sh
/path/to/quick-ui/quickui init --cwd /path/to/project
/path/to/quick-ui/quickui omarchy install --recipe quickui-omarchy.json --cwd /path/to/project --dry-run
/path/to/quick-ui/quickui omarchy install --recipe quickui-omarchy.json --cwd /path/to/project
```

Skip `init` when the project already has `quickui.json`. The command honors its `componentsDir` (default `ui`). It copies `HostTheme.qml`, generates `PresetTheme.qml` and `OmarchyPreset.qml` there, and copies the optional sources and attribution to `quickui-omarchy/` at the project root. Install additional controls normally, for example `quickui add button --cwd /path/to/project`.

A **preset code** such as `q1-6bi` encodes the portable preset and retains its original meaning. An **Omarchy recipe** adds the host-follow choices; a preset code alone cannot reproduce those choices. The JSON recipe is versioned separately:

```json
{
  "schemaVersion": 1,
  "kind": "quickui-omarchy",
  "preset": "q1-6bi",
  "follow": {
    "colors": true,
    "typography": true,
    "radius": true,
    "spacing": true
  },
  "radiusMultiplier": 1
}
```

Each follow field is required and boolean. `radiusMultiplier` accepts finite numbers from 0 to 2: 0 gives square host corners, 0.5 halves them, and 1 preserves the host radius. It only scales host geometry; without host radius tokens, the exact preset radius remains the fallback.

| Choice | Following the host | Explicit override |
| --- | --- | --- |
| Colors | Resolved shell colors, surfaces, selection and focus | Preset palette/accent |
| Typography | Resolved font family, sizes and font scale | Preset font settings |
| Radius | Host corner radius × multiplier | Preset radius |
| Spacing | Resolved padding, gaps, control/handle sizes and border widths | Preset density and border settings |
| Motion | Always the preset setting | Set motion to normal or none in Create |

## Inside an Omarchy shell plugin

Use the shell's already-resolved `Color` and `Style` objects. The adapter updates through QML bindings, including runtime theme and font changes:

```qml
import QtQuick
import qs.Commons
import "ui" as UI
import "quickui-omarchy" as Omarchy

Item {
    Omarchy.ShellThemeSource {
        id: host
        colorSource: Color
        styleSource: Style
    }
    UI.OmarchyPreset {
        id: tokens
        hostTokens: host.tokens
    }
    UI.Button {
        theme: tokens
        text: "Open workspace"
    }
}
```

Paths in these examples are relative to the consuming QML file; adjust them to your project layout. The optional source imports no `qs.Commons` module itself: only the consuming Omarchy plugin needs it.

## Standalone Quickshell application

Use `DesktopThemeSource` outside Omarchy's shell:

```qml
import QtQuick
import "ui" as UI
import "quickui-omarchy" as Omarchy

Item {
    Omarchy.DesktopThemeSource {
        id: host
        enabled: true
    }
    UI.OmarchyPreset {
        id: tokens
        hostTokens: host.tokens
        // Optional light fallback when the host is unavailable:
        presetTheme: UI.PresetTheme { dark: false }
    }
    UI.Button { theme: tokens; text: "Open workspace" }
}
```

The standalone bridge requires Quickshell and Python 3.11+ (`tomllib`). It starts disabled. When enabled, it polls the resolved active theme and user shell settings; changes become visible on the next refresh (default 1.5 seconds). It reopens paths so atomic theme-directory replacements are followed. Theme reads are bounded and read-only; it never activates a theme or runs configuration as code. Desktop font/compositor queries supplement the files when available. A matching Wayland session or a sole Hyprland instance can be discovered when the launch environment lacks its instance signature. An ambiguous or unavailable compositor leaves the preset radius intact and reports a warning; it does not silently turn rounded themes square.

The source exposes `tokens`, `available`, `error`, `name`, and `enabled`. `error` can also contain a nonfatal warning while theme colors are available. When unavailable or malformed, it clears host tokens and the preset takes over. Disabling it stops refresh work. For a synthetic fixture, set `themeDirectory`, `userShellPath`, and `querySystem: false`. This also permits native preview tests without changing the live desktop.

The standalone bridge reproduces supported resolved settings from the active theme, user shell configuration, and available desktop queries. A shell plugin should use `ShellThemeSource` for the authoritative live `Color`/`Style` objects, including shell-specific runtime changes.

## Source ownership and updates

Installation checks all destinations and metadata before writing, then stages the complete plan with rollback on failure. Dry runs do not create directories or change timestamps. Reapplying an unchanged recipe is a no-op.

Existing edited `Theme.qml` and other controls are preserved. Optional integration destinations refuse replacement when edited or unowned, even when an unowned file happens to match the bundled bytes. An unchanged `HostTheme.qml` previously installed by the registry can be adopted. Existing generated presets must have a matching `quickui.json` ownership record. Fingerprints for optional files live in the separate `omarchy` record; portable generated-preset metadata remains in `preset`.

If you customize a generated wrapper or adapter, keep your changes and merge future updates manually, or install into a fresh project for comparison. There is no force-overwrite option. Changing `componentsDir` after installation requires deliberate migration of files and metadata.

`quickui preset apply CODE` updates the portable fallback only. To change and record host-follow choices as well, export and install a new Omarchy recipe. No command automatically rewrites your shell entrypoint: wire `hostTokens` and pass the resulting `theme` to your controls as shown above.

See `LICENSE.omarchy` for upstream attribution carried with the copied integration sources.
