import QtQuick
import QtQuick.Layouts
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    onArgsChanged: { workspaceName.text = ""; notifications.checked = true; }
    signal eventRaised(string name, var payload)
    implicitWidth: 320
    implicitHeight: card.implicitHeight
    UI.Theme {
        id: tokens
        dark: root.dark
        accent: root.args.palette === "Ocean" ? (dark ? "#72dce8" : "#096c83") : root.args.palette === "Rose" ? (dark ? "#f4a2bf" : "#aa335d") : (dark ? "#b4a0ff" : "#7152cf")
        radius: root.args.radius ?? 8
        density: root.args.density ?? "default"
        fontScale: root.args.fontScale ?? 1
        controlHeight: root.args.height ?? (density === "compact" ? 30 : density === "comfortable" ? 44 : 36)
        selection: root.args.subduedSelection === true ? surfaceHover : accent
        selectionForeground: root.args.subduedSelection === true ? foreground : accentForeground
        motionDuration: root.args.reduceMotion === true ? 0 : 120
    }
    UI.Card {
        id: card
        anchors.fill: parent
        theme: tokens
        ColumnLayout {
            width: card.availableWidth
            spacing: tokens.spacing * 2
            Text { text: "One theme. Every component."; color: tokens.foreground; font.pixelSize: tokens.fontSize; font.bold: true }
            UI.Badge { theme: tokens; text: root.args.palette ?? "Lavender"; variant: "accent" }
            UI.TextField { id: workspaceName; objectName: "themeWorkspaceName"; Layout.fillWidth: true; theme: tokens; placeholderText: "Workspace name"; Accessible.name: "Workspace name" }
            UI.Switch { id: notifications; objectName: "themeNotifications"; theme: tokens; text: "Notifications"; checked: true; onToggled: root.eventRaised("toggled", {checked: checked}) }
            UI.Button { Layout.fillWidth: true; theme: tokens; text: "Save preferences"; onClicked: root.eventRaised("clicked", {}) }
        }
    }
}
