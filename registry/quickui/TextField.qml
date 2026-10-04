import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.TextField {
    id: control
    property Theme theme: Theme {}
    property bool invalid: false
    property string size: "default"

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.spacing
    leftPadding: theme.paddingFor(size)
    rightPadding: theme.paddingFor(size)
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    color: theme.foreground
    placeholderTextColor: theme.mutedForeground
    selectionColor: theme.selection
    selectedTextColor: theme.selectionForeground

    background: Rectangle {
        implicitWidth: control.theme.heightFor(control.size) * 6
        implicitHeight: control.theme.heightFor(control.size)
        radius: control.theme.radius
        color: control.theme.surface
        border.width: control.activeFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.invalid ? control.theme.destructive : control.activeFocus ? control.theme.focus
            : control.hovered ? control.theme.mutedForeground : control.theme.border
        Behavior on border.color { ColorAnimation { duration: control.theme.motionDuration } }
    }
}
