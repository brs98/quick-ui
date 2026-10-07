# ListItem

Install `list-item` and import the copied source as `UI`. ListItem is a native
Qt Quick Controls `ItemDelegate`: pointer release and Space activate `clicked`,
Tab reaches it, and `enabled`, `focusPolicy`, `hovered`, `down`, native actions,
and checkable-button behavior remain available. It does not manage a list's
model, selection, scrolling, or navigation keys.

```qml
UI.ListItem {
    width: 320
    theme: tokens
    text: "Design updates"
    description: "Three unread messages"
    selected: view.selectedId === modelData.id
    onClicked: view.open(modelData.id)
}
```

## Presentation and state

- `theme`: shared `UI.Theme`; `size`: `sm`, `default`, or `lg`.
- `text`: plain-text title with trailing elision at constrained widths.
- `description`: plain-text secondary label that wraps. Implicit height grows
  for its text, slot content, larger fonts, and padding.
- `selected`: caller-owned persistent selection; clicks never change it.
- Native `highlighted`: caller-owned navigation/attention highlight, independent
  of `selected`, native `checked`, and keyboard focus.
- `foregroundColor` and `descriptionColor`: readonly themed colors for custom
  content. Selected/highlighted rows use the selection color pair. Other rows
  use foreground/muted foreground, a subtle hovered/pressed fill, and a
  transparent idle background. Keyboard focus has a separate outside ring.

Explicit dimensions and native padding properties remain available. `padding: 0`
removes all default padding, useful when adapting an existing row layout. Keep
room around the row if its outside focus ring must remain visible in a clipped
container. Long titles are exposed in full through accessibility even when the
visual title elides.

`Accessible.name` defaults to `text`, `Accessible.description` to `description`,
and `Accessible.selected` to `selected`. The root has the ListItem role and a
native press action; default visual labels and icons are decorative. Override
the name/description when a custom presentation requires a different reading.
Set `Accessible.selectable: false` for a row that only performs an action and
has no selection semantics.

## Leading and trailing content

`leading` and `trailing` are optional Component slots. Each creates an Item whose
`implicitWidth` and `implicitHeight` define its desired size. Slots are vertically
centered; their actual widths are constrained to the row, leaving nonnegative
space for labels. Define their components inline when they reference the row or
its model. Layouts and labels belong to the slot; ListItem does not guess their
accessibility semantics.

```qml
UI.ListItem {
    id: row
    width: 320
    theme: tokens
    text: "Team chat"
    description: "Latest update"
    leading: Rectangle {
        implicitWidth: 36; implicitHeight: 36; radius: 18
        color: row.theme.primary
        Accessible.ignored: true
    }
    trailing: UI.IconButton {
        theme: row.theme
        text: "⋯"
        accessibleLabel: "More chat actions"
        variant: "ghost"
        onClicked: view.openActions()
    }
    onClicked: view.openChat()
}
```

Install the slot components separately (`./quickui add list-item icon-button`).
A nested native button consumes its own activation instead of also activating
the row, and participates in normal Tab navigation. A leading slot overrides
the built-in native `icon.name`/`icon.source` renderer. Without a leading slot,
icons support theme lookup and source fallback; `icon.color: "transparent"`
preserves source colors. Slots swap sides under inherited RTL mirroring.

## Rich rows and externally owned navigation

Override the standard `contentItem` for article layouts, avatars, timestamps,
message previews, or multiple actions that need a different arrangement. Give it
an implicit height (or explicitly size the row); the control supplies its actual
available width/height. Default labels and slots are not part of this custom
presentation. Keep `text`/`description` populated for accessibility.

```qml
UI.ListItem {
    id: row
    width: list.width
    padding: 0
    text: modelData.title
    description: modelData.summary
    focusPolicy: Qt.NoFocus
    highlighted: controller.cursorActive && index === controller.cursor
    contentItem: Item {
        implicitWidth: 0
        implicitHeight: 92
        // Existing rich row layout; use row.foregroundColor where appropriate.
    }
    onHoveredChanged: if (hovered) controller.cursor = index
    onClicked: controller.open(index)
}
```

`Qt.NoFocus` preserves a panel's central key handler; the owner handles arrow
keys, activation, dismissal, and scrolling. `highlighted` is visual and does not
claim accessibility focus or persistent selection. If keyboard navigation must
clear every visual trace of a stationary pointer, disable native hover with
`hoverEnabled: false` and use a separate `HoverHandler` to update the owner's
cursor. This keeps exactly one highlighted row without conflating the cursor
with selection.

The implementation uses public [ItemDelegate](https://doc.qt.io/qt-6/qml-qtquick-controls-itemdelegate.html)
and [Loader](https://doc.qt.io/qt-6/qml-qtquick-loader.html) APIs.
