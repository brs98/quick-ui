# Dialogs

Install `quickui add dialog` for a composable dialog or `quickui add alert-dialog`
for a confirmation. Both use public Qt Quick Controls, run inside normal Qt Quick
windows and Quickshell windows, and need no shell services or native platform
dialog integration.

## Dialog

`Dialog` extends `QtQuick.Controls.Basic.Dialog`. It adds `theme` and `size`
(`sm`, `default`, `lg`). Native `title`, `header`, `contentItem`, `footer`,
`standardButtons`, `standardButton()`, `open()`, `close()`, `accept()`, `reject()`,
`accepted`, `rejected`, and `closed` remain available.

The default is modal, focused, and `Popup.Item`. It centers within its parent,
clamps its width to that parent, and uses the theme's popup palette. Its title is
plain, wrapped text. The default footer styles native standard buttons with
QuickUI Button and retains Qt's platform button order and button roles. Return,
keypad Enter, and Space activate a focused footer button.

```qml
import QtQuick
import "ui" as UI

UI.Dialog {
    id: editDialog
    title: "Rename workspace"
    standardButtons: UI.Dialog.Save | UI.Dialog.Cancel
    UI.TextField { id: name; text: "Workspace"; theme: editDialog.theme }
    onOpened: name.forceActiveFocus(Qt.TabFocusReason)
    onAccepted: console.log("Requested name:", name.text)
}
```

Custom content owns its initial focus, validation, and scrolling. For large forms,
set a suitable height and provide a ScrollView; general Dialog does not constrain
arbitrary content height. For many actions or unusually long localized standard
button labels, supply a responsive custom footer. Explicit child controls should
receive the same theme. Replacing the footer with a native DialogButtonBox wires
its accepted/rejected roles automatically; do not also call accept/reject from
those buttons. A custom ordinary footer instead calls these methods itself.

## AlertDialog

`AlertDialog` extends QuickUI Dialog with:

| Property | Default | Purpose |
| --- | --- | --- |
| `description` | `""` | Plain, wrapped, scrollable explanatory text |
| `confirmText` | translated `"Continue"` | Confirm action label |
| `cancelText` | translated `"Cancel"` | Cancel action label |
| `variant` | `"destructive"` | Confirm Button variant; use `"primary"` for ordinary confirmation |
| `confirmEnabled` | `true` | Disable user confirmation while a request is unavailable |
| `confirmButton`, `cancelButton` | readonly aliases | Native Buttons for inspection and focused host tests |

```qml
UI.AlertDialog {
    id: removeDialog
    title: "Remove workspace?"
    description: "Its saved layout will be removed."
    confirmText: "Remove"
    onAccepted: workspaceModel.remove(pendingWorkspaceId)
}
```

Cancel receives keyboard focus on every open, including after a previous confirm.
Tab/Backtab move within the modal popup; Left/Right move between actions. Return,
keypad Enter, and Space activate the focused action. Escape rejects. Outside
presses are blocked and do not dismiss. The footer stacks actions and wraps their
labels when necessary; the description scrolls when the host is short. The dialog
exposes an accessible Dialog role/name and description on its popup visual item.

AlertDialog uses its own responsive footer, not `standardButtons`. Each button
calls native accept/reject once. Listen to `onAccepted`/`onRejected` for the result;
attaching another business callback to the button would duplicate your action.
`confirmEnabled` guards user interaction, not direct calls to native `accept()`.

## Host ownership and dismissal

Qt restores focus to the previously focused item on close. A host with its own
key catcher must let the popup own focus while visible. Do not reclaim outer focus
after `open()`, and do not forward the same key both to the popup and a host
confirmation handler. Capture the intended target before opening, then validate
that captured request in `onAccepted`; visibility/opened is already false when
native result handlers run. These service and selection guards belong to the host.

On the tested Qt 6.11.2, general Dialog's Escape and outside-press policies reject
once. AlertDialog rejects through Cancel or Escape only. Explicit `close()` or
setting `visible: false` emits no accepted/rejected result; use `closed` for
unconditional teardown. This also lets hosts quietly close an obsolete request.

For per-popup RTL in a host whose overlay is outside its mirrored subtree, mirror
the public visual parent explicitly (as with QuickUI Menu):

```qml
Binding { target: dialog.contentItem.parent; property: "LayoutMirroring.enabled"; value: useRtl }
Binding { target: dialog.contentItem.parent; property: "LayoutMirroring.childrenInherit"; value: true }
```

The implementation uses public APIs described in Qt's
[Dialog](https://doc.qt.io/qt-6/qml-qtquick-controls-dialog.html),
[DialogButtonBox](https://doc.qt.io/qt-6/qml-qtquick-controls-dialogbuttonbox.html),
and [Popup](https://doc.qt.io/qt-6/qml-qtquick-controls-popup.html) documentation.

## Verification

Run the warning-fatal native interaction suite:

```sh
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  /usr/lib/qt6/bin/qmltestrunner -input tests/tst_quickui_dialogs.qml
```

It covers native result counts, default Cancel and focus restoration through repeated
opens, pointer and keyboard activation, modal Tab containment, disabled confirmation,
Escape/outside policy, result-neutral close, standard buttons and custom form content,
plain text, RTL, theme scaling, and narrow/long-label layout.
