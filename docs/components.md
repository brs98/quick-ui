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
| `button` / `UI.Button` | Native `text`, `icon`, `display`; `variant`, `size`, `iconPosition`, `loading` | Native `clicked`, `toggled`; Space activation and Tab focus |
| `icon-button` / `UI.IconButton` | Button API; text glyph and `accessibleLabel` | Native button behavior with a nonvisual label |
| `text-field` / `UI.TextField` | `text`, `placeholderText`, `readOnly`, `validator`, `echoMode`, `invalid`, `size` | `textEdited`, `accepted`; native editing and selection |
| `field` / `UI.Field` | `label`, `description`, `errorText`, `requiredIndicator`, `invalid`, `control` | Label focuses its control; associates accessible name and feedback |
| `switch` / `UI.Switch` | `text`, `checked`, `description`, `multiline`, `invalid`, `size` | `toggled`; Space and pointer activation |
| `checkbox` / `UI.CheckBox` | Switch presentation API; `tristate`, `checkState` | `toggled`, native tristate and keyboard behavior |
| `slider` / `UI.Slider` | `from`, `to`, `stepSize`, `value`, `orientation` | `moved`; keyboard, drag, and track click |
| `range-slider` / `UI.RangeSlider` | `first.value`, `second.value`, `from`, `to`, `orientation`, `stepSize`, per-handle accessible names | Native independent handle focus, `first.moved`, `second.moved` |
| `select` / `UI.Select` | Native ComboBox API; `placeholderText`, `invalid`, `size`, `enabledRole` | `activated`; popup, available-option navigation, scrolling |
| `card` / `UI.Card` | Native Pane, `padding`, `size`, one layout child | Compose header, body, and footer in the layout |
| `badge` / `UI.Badge` | `text`, `variant`, `icon`, `statusDot`, `busy` | Noninteractive status label; constrained text elides |
| `separator` / `UI.Separator` | `vertical`, `semantic`; set width/height for your layout | Decorative by default; optional accessible separator |
| `menu` / `UI.Menu` | Native `title`, `open`, `popup`, actions and submenus; `size` | Native keyboard navigation, dismissal, and action dispatch |
| `menu-item` / `UI.MenuItem` | Native `text`, `icon`, `action`, `checkable`, `checked`; `variant`, `shortcutText`, `indicatorType` | Native `triggered`, `toggled`; pointer and keyboard activation |
| `menu-separator` / `UI.MenuSeparator` | `size`; set width for standalone layouts | Native nonselectable menu divider |

Button variants are `primary`, `secondary`, `ghost`, `outline`, and `destructive`.
Badge variants are `neutral`, `accent`, `outline`, and `destructive`. Labels render
plain text. Button, IconButton, and Badge render Qt theme icons and source images,
including native fallback from `icon.name` to `icon.source`. `icon.color:
"transparent"` preserves source colors; otherwise icons use their themed tint.
The installer includes the internal `icon-graphic` dependency automatically. It is
a decorative renderer, not a separate interactive control.

`size` accepts `sm`, `default`, and `lg`; explicit dimensions/padding still win.
IconButton keeps a square shape. Always supply an action name via
`accessibleLabel` (or `Accessible.name`), especially when `text` is a symbol.

Controls preserve Qt's native state ownership: user interaction can change
`checked`, `text`, `value`, or `currentIndex`. Use the native interaction signals to
update application state. For async desktop operations, keep pending/confirmed
state in an adapter and drive the control from that state. In Quickbook, changing
args or resetting a preset restores wrapper-local state.

Provide `Accessible.name` for fields, sliders, and selects without visible labels.
IconButton's `accessibleLabel` supplies its name. Keyboard/focus behavior is tested;
native accessibility values, selected states, actions, and the panel cursor are
also checked through QAccessible. Full screen-reader and cross-compositor audits
remain separate from those interface checks.

## Composition recipes

Field keeps validation timing with the consumer. A validator may consider an
unfinished edit intermediate; that alone must not display an error. Set `invalid`
on a control explicitly, or let Field bind it from `errorText`:

```qml
// ./quickui add field text-field --cwd ~/my-shell
// Also import QtQuick.Layouts in this consumer.
UI.Field {
    theme: tokens
    width: 300
    label: "Workspace name"
    description: "Shown in the workspace switcher."
    requiredIndicator: true
    errorText: submitted && name.text.length === 0 ? "Enter a name." : ""
    UI.TextField { id: name; theme: tokens; Layout.fillWidth: true }
}
```

The first child is the default `control`; assign `control` explicitly for more
complex content. Field binds its name/description while `manageAccessibility` is
true, restoring prior values/bindings when disabled. Set it false to own those
properties yourself. Required indication is descriptive; validation and submission
remain application responsibilities. Switch and CheckBox can instead use their
integrated `description` and `multiline` properties for clickable settings rows.

Buttons support leading/trailing icons with RTL-aware `iconPosition`, and native
`TextOnly`, `IconOnly`, `TextBesideIcon`, and `TextUnderIcon` display modes. Loading
preserves content dimensions and exposes a loading description:

```qml
UI.Button {
    theme: tokens
    text: "Save changes"
    icon.name: "document-save"
    icon.source: "icons/save.svg" // consumer-owned fallback
    loading: saving
    onClicked: {
        if (loading) return; // preserve focus while rejecting repeated requests
        saveRequested();
    }
}
```

`loading` is presentation only. Guard the action as above, or bind
`enabled: !loading` if disabling the control is the desired policy. Badge's `busy`
is likewise presentation only. Both respect `motionDuration: 0`.

Select supports an unselected state through `currentIndex: -1` and
`placeholderText`. Set `enabledRole: "available"` for model rows whose boolean
`available` role is false to be skipped by pointer, keyboard, and wheel selection.
Missing roles remain available. Programmatic `currentIndex` remains consumer-owned;
the component does not silently choose a new device when availability changes.
Editable ComboBox completion remains native; it is not a filtered search popup.

Slider retains native `live`, `snapMode`, `stepSize`, and `orientation`. Use
`live: false` for pointer-release updates, and `SnapAlways` with `stepSize` for
snapped dragging. Keyboard changes remain immediate. SliderStory demonstrates a
`valueCommitted` event recipe that combines `moved` and `pressed` without treating
programmatic updates as user commits. RangeSlider adds two native handles;
provide descriptive `firstAccessibleName` and `secondAccessibleName` values.

Card uses one content child, normally `ColumnLayout { width: card.availableWidth }`.
Two unrelated direct children neither stack nor determine Pane's content size.
The Card story shows a wrapping title, body, and responsive footer actions;
ordinary layouts can add header actions without new slot APIs. Use
`Layout.fillWidth`/`Layout.fillHeight` for separators in layouts. `semantic: true`
includes a separator in the accessibility tree without adding a keyboard stop.

## Menus

`./quickui add menu --cwd ~/my-shell` installs Menu, MenuItem, MenuSeparator, Theme,
and the icon renderer. Menu uses Qt's QML popup surface (`Popup.Item`), so it works
inside a Quickshell window and retains QuickUI styling. The consumer owns the window
and decides where to open it. Pass the same theme explicitly to composed items and
submenus; delegates created for native actions/submenus inherit their menu's theme.

```qml
UI.Button {
    id: trigger
    theme: tokens
    text: "Actions"
    onClicked: actions.open()
    UI.Menu {
        id: actions
        theme: tokens
        y: trigger.height
        UI.MenuItem { theme: tokens; text: "New workspace"; onTriggered: createWorkspace() }
        UI.MenuItem { theme: tokens; text: "Show bar"; checkable: true; checked: true }
        UI.MenuSeparator { theme: tokens }
        UI.Menu {
            theme: tokens
            title: "Appearance"
            UI.MenuItem { theme: tokens; text: "Dark"; checkable: true; autoExclusive: true; checked: true }
            UI.MenuItem { theme: tokens; text: "Light"; checkable: true; autoExclusive: true }
        }
    }
}
```

`variant: "destructive"` styles destructive actions. Native `Action` objects can
own `text`, `icon`, `enabled`, `checked`, and shortcuts. `shortcutText` is a display
hint only: use an Action's `shortcut` to register a key binding. `indicatorType`
accepts `auto`, `check`, or `radio`; `auto` follows `autoExclusive`. When using a
native `ActionGroup` for exclusivity, set `indicatorType: "radio"` explicitly.
`partiallyChecked` displays a mixed-state dash without changing native boolean
`checked` behavior. Consumers must clear or update that presentation state.

Native submenus display a chevron automatically. `hasSubmenu` also allows adapters
to display one while managing navigation in their own host. Standalone MenuItem
and MenuSeparator rows can be installed separately for those hosts; the adapter
then owns focus, navigation, dismissal, and external state synchronization. The
host also owns `highlighted`: synchronize it with a shared cursor when mixing
pointer and keyboard navigation, or bind it to `hovered` for a pointer-only row.
MenuItem does not independently highlight a hovered row after the keyboard cursor
moves elsewhere. The Omarchy tray is one such adapter, keeping D-Bus menu entries and opener lifetimes
outside the library. See [the standalone example](../templates/menu.qml).

## Audio controls and blocks

`tooltip`, `level-meter`, and `device-item` are reusable primitives. The
`volume-control` and `audio-mixer` entries compose them with the foundation controls.
Unlike native primitive state, these audio blocks use controlled requests: owners
accept a request and update the public value. A rejected request cannot silently
change confirmed backend state. See [audio controls](audio-controls.md) and
[mixer API](audio-mixer.md) for properties, signals, and keyboard modes.

## Theme tokens

`Theme` is a normal object, not a global singleton, so two themes can coexist.
Editable tokens include:

- Semantic colors: `background`, `surface`, `surfaceHover`, `foreground`,
  `mutedForeground`, `border`, `accent`, `accentForeground`, `destructive`,
  `destructiveForeground`, and `focus`.
- Overridable role pairs: `primary`/`primaryForeground`,
  `selection`/`selectionForeground`, `popup`/`popupForeground`, and
  `card`/`cardForeground`. They default to the original accent/surface tokens.
- Typography: `fontFamily`, `fontSize`, `smallFontSize`.
- Geometry: `radius`, `controlHeight`, `padding`, `spacing`, `borderWidth`, `focusWidth`.
- Scale: `fontScale` (default 1), `density` (`compact`, `default`, `comfortable`),
  `radiusSmall`, `radiusLarge`, and `handleSize`. `heightFor(size)` and
  `paddingFor(size)` derive per-control sizes. Direct token overrides remain valid.
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

The original action, volume, and notification examples now compose QuickUI primitives
under `examples/`, retaining their demonstration APIs; they are not separate entries in the QuickUI installer. The new `audio-mixer` is an installable block; window hosting remains in its consumer.
Native window primitives, remote registries, updates/diffs, and further blocks remain
later milestones.
