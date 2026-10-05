import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property alias control: separator
    signal eventRaised(string name, var payload)
    implicitWidth: 300
    implicitHeight: card.implicitHeight
    UI.Theme {
        id: tokens
        dark: root.dark
        density: root.args.density ?? "default"
        fontScale: root.args.fontScale ?? 1
    }
    UI.Card {
        id: card
        width: parent.width
        theme: tokens
        padding: tokens.spacing / 2
        Column {
            width: card.availableWidth
            UI.MenuItem {
                highlighted: hovered
                width: parent.width
                theme: tokens
                text: "Workspace actions"
                onTriggered: root.eventRaised("workspaceRequested", {})
            }
            UI.MenuSeparator {
                id: separator
                width: parent.width
                theme: tokens
            }
            UI.MenuItem {
                highlighted: hovered
                width: parent.width
                theme: tokens
                text: "Preferences"
                onTriggered: root.eventRaised("preferencesRequested", {})
            }
        }
    }
}
