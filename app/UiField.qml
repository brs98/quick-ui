import QtQuick
import QtQuick.Controls.Basic

TextField {
    id: root
    required property var theme
    implicitHeight: 36
    leftPadding: 11
    rightPadding: 11
    color: theme.text
    placeholderTextColor: theme.muted
    selectionColor: theme.accent
    selectedTextColor: theme.bg
    font.pixelSize: 12
    selectByMouse: true
    background: Rectangle {
        radius: 7
        color: root.theme.bg
        border.color: root.activeFocus ? root.theme.accent : root.theme.line
    }
}
