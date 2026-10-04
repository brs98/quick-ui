import QtQuick
import QtQuick.Controls.Basic

Rectangle {
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
    implicitHeight: content.implicitHeight + 44
    radius: 20
    color: dark ? "#222335" : "#ffffff"
    border.color: dark ? "#39394d" : "#e1ddeb"

    Rectangle {
        x: 22; y: 24; width: 34; height: 34; radius: 10
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, root.dark ? 0.15 : 0.25)
        Text {
            anchors.centerIn: parent
            text: root.severity === "success" ? "✓" : root.severity === "warning" ? "!" : "i"
            font.pixelSize: 18; font.weight: Font.DemiBold
            color: root.dark ? root.accent : "#625176"
        }
    }
    Column {
        id: content
        x: 72; y: 22; width: parent.width - 96
        spacing: 10
        Text {
            width: parent.width - 22
            text: root.sourceName
            elide: Text.ElideRight
            font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1.3
            color: root.dark ? "#9d9ab4" : "#7a728a"
        }
        Text {
            width: parent.width
            text: root.title; wrapMode: Text.WordWrap
            font.pixelSize: 17; font.weight: Font.DemiBold
            color: root.dark ? "#f1eef9" : "#2b253d"
        }
        Text {
            width: parent.width
            text: root.message; wrapMode: Text.WordWrap
            font.pixelSize: 13; lineHeight: 1.35
            color: root.dark ? "#aaa7bf" : "#777082"
        }
        Item { width: 1; height: 2; visible: root.showAction }
        ActionButton {
            visible: root.showAction
            text: root.actionLabel
            dark: root.dark; tone: "secondary"; height: 36
            width: Math.min(implicitWidth, parent.width)
            onClicked: root.actionRequested()
        }
    }
    AbstractButton {
        id: dismissButton
        anchors.right: parent.right; anchors.rightMargin: 12
        y: 10; width: 32; height: 32
        hoverEnabled: true
        Accessible.name: "Dismiss notification"
        background: Rectangle {
            radius: 8
            color: dismissButton.hovered || dismissButton.activeFocus ? (root.dark ? "#35354a" : "#f0ecf7") : "transparent"
        }
        contentItem: Text {
            text: "×"; font.pixelSize: 22
            color: root.dark ? "#a8a5bd" : "#80758e"
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        }
        onClicked: root.dismissRequested()
    }
}
