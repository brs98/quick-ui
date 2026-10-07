import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import "ui" as UI

// Install alert-dialog + text-field, then copy beside ui/ as shell.qml.
// Every action updates only this demonstration's local state.
ShellRoot {
    id: root
    property string workspaceName: "Personal workspace"
    property string lastAction: "No removal requested"
    UI.Theme { id: tokens }
    FloatingWindow {
        title: "QuickUI — Dialogs"
        implicitWidth: 620; implicitHeight: 460
        color: tokens.background
        Rectangle {
            id: page
            anchors.fill: parent
            color: tokens.background
            function capture(path: string): bool {
                Controls.Overlay.overlay.parent = page;
                return page.grabToImage(result => result.saveToFile(path));
            }
            Column {
                x: 32; y: 32; spacing: tokens.spacing
                UI.Button { theme: tokens; text: "Edit workspace"; onClicked: editor.open() }
                UI.Button { theme: tokens; text: "Remove workspace"; variant: "outline"; onClicked: confirmation.open() }
                Text { textFormat: Text.PlainText; text: root.workspaceName; color: tokens.foreground; font.pixelSize: tokens.fontSize }
                Text { text: root.lastAction; color: tokens.mutedForeground; font.pixelSize: tokens.fontSize }
            }
            UI.Dialog {
                id: editor
                theme: tokens
                title: "Edit workspace"
                standardButtons: Controls.Dialog.Save | Controls.Dialog.Cancel
                contentItem: UI.TextField { id: nameField; theme: tokens; Accessible.name: "Workspace name" }
                onOpened: { nameField.text = root.workspaceName; nameField.forceActiveFocus(Qt.TabFocusReason); }
                onAccepted: root.workspaceName = nameField.text
            }
            UI.AlertDialog {
                id: confirmation
                theme: tokens
                title: "Remove workspace?"
                description: "This sample emits a local event. No files or workspaces are changed."
                confirmText: "Remove"
                cancelText: "Keep workspace"
                onAccepted: root.lastAction = "Removal requested"
                onRejected: root.lastAction = "Workspace kept"
            }
        }
    }
    Connections { target: Quickshell; function onLastWindowClosed() { Qt.quit(); } }
    IpcHandler {
        target: "quickui-dialogs"
        function openEditor(): void { editor.open(); }
        function saveName(name: string): void { nameField.text = name; editor.standardButton(Controls.Dialog.Save).click(); }
        function openAlert(): void { confirmation.open(); }
        function confirm(): void { confirmation.confirmButton.click(); }
        function cancel(): void { confirmation.cancelButton.click(); }
        function theme(dark: bool): void { tokens.dark = dark; }
        function status(): string {
            return JSON.stringify({editor: editor.opened, alert: confirmation.opened,
                cancelFocused: confirmation.cancelButton.activeFocus, dark: tokens.dark,
                accent: String(tokens.accent), name: root.workspaceName, action: root.lastAction});
        }
        function capture(path: string): bool { return page.capture(path); }
    }
}
