import QtQuick
import "../registry/quickui" as UI

UI.Card {
    id: root
    property bool dark: true
    property string title: "Your workspace is ready"
    property string message: "Everything is right where you left it. Pick up where you paused."
    property string sourceName: "QUICKBOOK"
    property string actionLabel: "Open workspace"
    property string severity: "info"
    property bool showAction: true
    readonly property color accent: severity === "success" ? "#97d7b6" : severity === "warning" ? "#e7bc7c" : "#b4a0ff"
    signal actionRequested()
    signal dismissRequested()

    implicitWidth: 384
    theme: UI.Theme { dark: root.dark; padding: 22; radiusLarge: 20 }

    Item {
        width: root.availableWidth
        implicitHeight: Math.max(34, content.implicitHeight)
        Rectangle {
            y: 2; width: 34; height: 34; radius: 10
            color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, root.dark ? 0.15 : 0.25)
            Text {
                anchors.centerIn: parent
                text: root.severity === "success" ? "✓" : root.severity === "warning" ? "!" : "i"
                textFormat: Text.PlainText
                font.family: root.theme.fontFamily
                font.pixelSize: 18; font.weight: Font.DemiBold
                color: root.dark ? root.accent : root.theme.foreground
                Accessible.ignored: true
            }
        }
        Column {
            id: content
            x: 50
            width: Math.max(0, parent.width - x)
            spacing: 10
            Text {
                width: Math.max(0, parent.width - 22)
                text: root.sourceName
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.family: root.theme.fontFamily
                font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1.3
                color: root.theme.mutedForeground
            }
            Text {
                width: parent.width
                text: root.title
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                font.family: root.theme.fontFamily
                font.pixelSize: 17; font.weight: Font.DemiBold
                color: root.theme.cardForeground
            }
            Text {
                width: parent.width
                text: root.message
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                font.family: root.theme.fontFamily
                font.pixelSize: 13; lineHeight: 1.35
                color: root.theme.mutedForeground
            }
            Item { width: 1; height: 2; visible: root.showAction }
            UI.Button {
                visible: root.showAction
                text: root.actionLabel
                theme: root.theme
                variant: "secondary"
                width: Math.min(implicitWidth, parent.width)
                onClicked: root.actionRequested()
            }
        }
        UI.IconButton {
            objectName: "exampleDismissButton"
            anchors.right: parent.right
            anchors.rightMargin: -10
            y: -12
            theme: root.theme
            size: "sm"
            text: "×"
            font.pixelSize: 22
            accessibleLabel: qsTr("Dismiss notification")
            variant: "ghost"
            onClicked: root.dismissRequested()
        }
    }
}
