# QuickUI component APIs

Install from the repository with `./quickui add <name> --cwd <project>` and import
with `import "ui" as UI`. Qt Quick and Qt Quick Controls are runtime dependencies;
there is no Omarchy dependency. Tested on Quickshell 0.3.1 / Qt 6.11.2. Other Qt 6
versions are not yet in a compatibility matrix.

Every component has a `theme` property accepting a `UI.Theme`. If omitted, the
component creates a default theme. Pass a single object to keep a group consistent:

```qml
UI.Theme { id: appearance; dark: false; radius: 4 }
UI.Button { theme: appearance; text: "Save" }
UI.Switch { theme: appearance; text: "Notifications" }
```

## Primitives

| Registry entry / QML type | Main API | User interaction |
| --- | --- | --- |
| `button` / `UI.Button` | `text`, `variant`, `enabled`, `checkable`, `checked` | Native `clicked`, `toggled`; Space/Enter and Tab focus |
| `icon-button` / `UI.IconButton` | Button API; text glyph and `accessibleLabel` | Native button behavior with a nonvisual label |
| `text-field` / `UI.TextField` | `text`, `placeholderText`, `readOnly`, `validator`, `echoMode` | `textEdited`, `accepted`; native editing and selection |
| `switch` / `UI.Switch` | `text`, `checked`, `enabled` | `toggled`; Space and pointer activation |
| `checkbox` / `UI.CheckBox` | `text`, `checked`, `tristate`, `checkState` | `toggled`, native tristate and keyboard behavior |
| `slider` / `UI.Slider` | `from`, `to`, `stepSize`, `value`, `orientation` | `moved`; keyboard, drag, and track click |
| `select` / `UI.Select` | `model`, `textRole`, `currentIndex`, `currentText`, `editable` | `activated`; popup, keyboard selection, scrolling |
| `card` / `UI.Card` | Native Pane, `padding`, default QML content | Compose ordinary items/layouts inside it |
| `badge` / `UI.Badge` | `text`, `variant` | Status display |
| `separator` / `UI.Separator` | `vertical`; set width/height for your layout | Decorative divider |

Button variants are `primary`, `secondary`, `ghost`, and `destructive`. Badge
variants are `neutral`, `accent`, and `destructive`. Labels render plain text.
Button and IconButton render text/glyphs in this version; Qt's `icon.name` and
`icon.source` properties are inherited but not rendered. A dedicated image/icon
system is deferred.

Controls preserve Qt's native state ownership: user interaction can change
`checked`, `text`, `value`, or `currentIndex`. Use the native interaction signals to
update application state. For async desktop operations, keep pending/confirmed
state in an adapter and drive the control from that state. In Quickbook, changing
args or resetting a preset restores wrapper-local state.

Provide `Accessible.name` for fields, sliders, and selects without visible labels.
IconButton's `accessibleLabel` supplies its name. Keyboard/focus behavior is tested;
full screen-reader and cross-compositor accessibility audits remain future work.

## Theme tokens

`Theme` is a normal object, not a global singleton, so two themes can coexist.
Editable tokens include:

- Semantic colors: `background`, `surface`, `surfaceHover`, `foreground`,
  `mutedForeground`, `border`, `accent`, `accentForeground`, `destructive`,
  `destructiveForeground`, and `focus`.
- Typography: `fontFamily`, `fontSize`, `smallFontSize`.
- Geometry: `radius`, `controlHeight`, `padding`, `spacing`, `borderWidth`, `focusWidth`.
- Behavior: `motionDuration` (set to `0` to disable themed animations), `disabledOpacity`.

Default colors follow `dark`. Explicit color overrides belong to you: when changing
an accent, also choose a contrasting `accentForeground`. Switching `dark` updates
properties that still use their default bindings. You can override an instance or
edit the installed `ui/Theme.qml` defaults. Adding a new component preserves that
recorded, customized Theme dependency.

## Integration boundary

Primitives take state and emit events. They never inspect windows, read accounts,
change audio levels, or invoke shell commands. Put PipeWire, compositor, network,
and notification connections in separate consumers/adapters. The standalone
starter is one such mock consumer; the Omarchy News theme adapter is a real one.

The larger volume and notification example blocks are still demonstration code
under `examples/`; they are not entries in the QuickUI installer. Native panel and
popup-window primitives, remote registries, updates/diffs, and more complex blocks
are later milestones.
