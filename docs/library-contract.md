# QuickUI foundation contract

QuickUI distributes editable QML source; Quickbook renders that same source in stories.
The canonical files live in `registry/quickui/`. Installed files go into a local
`ui/` directory and are imported with `import "ui" as UI`. No global import-path,
compiled module, Omarchy service, registry process, or network connection is needed
at runtime.

Every component exposes `property Theme theme: Theme {}`. Consumers can pass one
shared `UI.Theme` instance, customize semantic colors and sizing, or edit installed
source directly. Theme is a normal object, not a singleton: multiple themes may
coexist in the same window. Controls retain normal Qt Quick properties, signals,
keyboard navigation, focus and accessibility behavior. Examples and adapters own
service connections; primitives only render state and emit interaction signals.

Foundation registry entries:

| Registry name | QML type | Dependencies |
| --- | --- | --- |
| theme | Theme | — |
| button | Button | theme |
| icon-button | IconButton | button |
| text-field | TextField | theme |
| field | Field | theme |
| switch | Switch | theme |
| checkbox | CheckBox | theme |
| slider | Slider | theme |
| range-slider | RangeSlider | theme |
| select | Select | theme |
| card | Card | theme |
| badge | Badge | theme |
| separator | Separator | theme |

Button variants: `primary`, `secondary`, `ghost`, `outline`, `destructive`. IconButton extends
Button and accepts `accessibleLabel` for its nonvisual name. TextField, Switch,
CheckBox, Slider, and Select follow Qt Quick Controls APIs (`text`, `checked`,
`value`, `model`, `currentIndex`, and their native interaction signals). Card is a
Pane with one padded layout child. Badge has `text` and `variant` (`neutral`,
`accent`, `outline`, `destructive`), icons, status dots, and busy presentation.
Separator has `vertical` and opt-in `semantic` (both default false).
Button and Badge additionally depend on internal `icon-graphic` for native Qt
icon lookup/tint/fallback without importing private Qt implementation modules.
Field composes a labeled control with consumer-owned errors. RangeSlider retains
Qt's native two-handle API; each handle has its own accessible name and value.

The installer must resolve dependencies before writing, reject unknown entries,
keep paths inside the target project, and refuse to overwrite edited explicit targets or unrelated
files. Previously installed, customized dependencies are kept as owned source. Re-adding identical sources is a no-op. Local customization is expected;
updates require a reviewed diff, not an unconditional overwrite. The first release
uses a bundled local registry; publishing and fetching remote registries are later
work.

Audio milestone entries: `tooltip` and `level-meter` depend on `theme`;
`device-item` depends on `theme`; `volume-control` composes `slider`, `icon-button`,
`tooltip`, and `level-meter`; `audio-mixer` composes `volume-control`, `device-item`,
`switch`, `separator`, and `tooltip`. The registry is authoritative for transitive
installation. Audio blocks accept plain state and emit requests; the consumer
owns service calls and confirmed state, including stable device-id lookup.
