import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import "ui" as UI

// Install menu + button, then copy this file beside ui/ as shell.qml.
// All actions change local demonstration state only.
ShellRoot {
    id: root
    property string lastAction: "Open the menu to try an action"
    UI.Theme { id: tokens }
    FloatingWindow {
        id: window
        title: "QuickUI — Menus"
        implicitWidth: 480; implicitHeight: 420
        color: tokens.background
        Rectangle {
            id: page
            anchors.fill: parent
            color: tokens.background
            function capture(path: string): bool {
                // Quickshell attaches its window after component completion.
                // Capture the popup and page together once that window exists.
                Controls.Overlay.overlay.parent = page;
                return page.grabToImage(result => result.saveToFile(path));
            }
            UI.Button {
                id: trigger
                x: 32; y: 32
                theme: tokens
                text: "Workspace actions"
                onClicked: actions.open()
            }
            Text {
                x: 32; y: 370; width: parent.width - 64
                text: root.lastAction
                color: tokens.mutedForeground
                font.family: tokens.fontFamily
                font.pixelSize: tokens.fontSize
                elide: Text.ElideRight
            }
            UI.Menu {
                id: actions
                parent: trigger
                y: trigger.height + tokens.spacing
                theme: tokens
                UI.MenuItem {
                    theme: tokens
                    id: firstAction
                    text: "New workspace"
                    icon.name: "document-new"
                    onTriggered: root.lastAction = "New workspace requested"
                }
                UI.MenuItem {
                    id: statusItem
                    theme: tokens
                    text: "Show status bar"
                    checkable: true; checked: true
                    onToggled: root.lastAction = checked ? "Status bar shown" : "Status bar hidden"
                }
                UI.MenuSeparator { theme: tokens }
                UI.Menu {
                    id: appearance
                    title: "Appearance"
                    theme: tokens
                    UI.MenuItem {
                        theme: tokens
                        text: "Dark theme"
                        checkable: true; autoExclusive: true
                        checked: tokens.dark
                        onTriggered: tokens.dark = true
                    }
                    UI.MenuItem {
                        theme: tokens
                        text: "Light theme"
                        checkable: true; autoExclusive: true
                        checked: !tokens.dark
                        onTriggered: tokens.dark = false
                    }
                }
                UI.MenuItem { theme: tokens; text: "Unavailable action"; enabled: false }
            }
        }
    }
    Connections { target: Quickshell; function onLastWindowClosed() { Qt.quit(); } }
    IpcHandler {
        target: "quickui-menu"
        function open(): void { actions.open(); }
        function close(): void { actions.close(); }
        function activateFirst(): void { firstAction.click(); }
        function toggleStatus(): void { statusItem.click(); }
        function theme(dark: bool): void { tokens.dark = dark; }
        function status(): string {
            return JSON.stringify({opened: actions.opened, count: actions.count,
                dark: tokens.dark, accent: String(tokens.accent), checked: statusItem.checked,
                action: root.lastAction});
        }
        function capture(path: string): bool { return page.capture(path); }
    }
}
