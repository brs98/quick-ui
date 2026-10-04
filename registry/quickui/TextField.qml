import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.TextField {
    id: control
    property Theme theme: Theme {}

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.spacing
    leftPadding: theme.padding
    rightPadding: theme.padding
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    color: theme.foreground
    placeholderTextColor: theme.mutedForeground
    selectionColor: theme.accent
    selectedTextColor: theme.accentForeground

    background: Rectangle {
        implicitWidth: control.theme.controlHeight * 6
        implicitHeight: control.theme.controlHeight
        radius: control.theme.radius
        color: control.theme.surface
        border.width: control.activeFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.activeFocus ? control.theme.focus
            : control.hovered ? control.theme.mutedForeground : control.theme.border
        Behavior on border.color { ColorAnimation { duration: control.theme.motionDuration } }
    }
}
