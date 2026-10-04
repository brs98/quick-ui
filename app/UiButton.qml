import QtQuick
import QtQuick.Controls.Basic

Button {
    id: root
    required property var theme
    property bool selected: false
    implicitHeight: 34
    implicitWidth: Math.max(34, label.implicitWidth + 24)
    padding: 10
    hoverEnabled: true
    contentItem: Text {
        id: label
        text: root.text
        color: root.enabled ? (root.selected ? root.theme.accent : root.theme.text) : root.theme.muted
        font.pixelSize: 12
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: 7
        color: root.selected ? root.theme.selected : root.down ? root.theme.line : root.hovered ? root.theme.raised : "transparent"
        border.width: 1
        border.color: root.activeFocus ? root.theme.accent : root.theme.line
        opacity: root.enabled ? 1 : 0.5
    }
}
