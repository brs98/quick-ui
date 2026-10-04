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

Initial registry entries:

| Registry name | QML type | Dependencies |
| --- | --- | --- |
| theme | Theme | — |
| button | Button | theme |
| icon-button | IconButton | button |
| text-field | TextField | theme |
| switch | Switch | theme |
| checkbox | CheckBox | theme |
| slider | Slider | theme |
| select | Select | theme |
| card | Card | theme |
| badge | Badge | theme |
| separator | Separator | theme |

Button variants: `primary`, `secondary`, `ghost`, `destructive`. IconButton extends
Button and accepts `accessibleLabel` for its nonvisual name. TextField, Switch,
CheckBox, Slider, and Select follow Qt Quick Controls APIs (`text`, `checked`,
`value`, `model`, `currentIndex`, and their native interaction signals). Card is a
Pane with padded default content. Badge has `text` and `variant` (`neutral`,
`accent`, `destructive`). Separator has `vertical` (default false).

The installer must resolve dependencies before writing, reject unknown entries,
keep paths inside the target project, and refuse to overwrite edited or unrelated
files. Re-adding identical sources is a no-op. Local customization is expected;
updates require a reviewed diff, not an unconditional overwrite. The first release
uses a bundled local registry; publishing and fetching remote registries are later
work.
