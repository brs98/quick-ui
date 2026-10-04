import QtQuick
import QtQuick.Controls.Basic

ComboBox {
    id: root
    required property var theme
    implicitHeight: 34
    implicitWidth: 140
    leftPadding: 10
    rightPadding: 28
    font.pixelSize: 12
    palette.text: theme.text
    palette.buttonText: theme.text
    palette.window: theme.panel
    palette.base: theme.panel
    palette.highlight: theme.selected
    palette.highlightedText: theme.accent
    contentItem: Text {
        text: root.displayText
        color: root.theme.text
        font: root.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    indicator: Text {
        x: root.width - 22
        anchors.verticalCenter: parent.verticalCenter
        text: "⌄"
        color: root.theme.muted
    }
    background: Rectangle {
        radius: 7
        color: root.theme.bg
        border.color: root.activeFocus ? root.theme.accent : root.theme.line
    }
}
