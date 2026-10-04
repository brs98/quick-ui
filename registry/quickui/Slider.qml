import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.Slider {
    id: control
    property Theme theme: Theme {}

    padding: 8
    implicitWidth: horizontal ? 200 : theme.controlHeight
    implicitHeight: horizontal ? theme.controlHeight : 200
    opacity: enabled ? 1 : theme.disabledOpacity

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        width: control.horizontal ? control.availableWidth : 4
        height: control.horizontal ? 4 : control.availableHeight
        radius: 2
        color: control.theme.border

        Rectangle {
            x: control.horizontal && control.mirrored ? parent.width - width : 0
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : parent.width
            height: control.horizontal ? parent.height : control.position * parent.height
            radius: 2
            color: control.theme.accent
        }
    }

    handle: Rectangle {
        implicitWidth: 18
        implicitHeight: 18
        x: control.leftPadding + (control.horizontal
            ? control.visualPosition * (control.availableWidth - width)
            : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal
            ? (control.availableHeight - height) / 2
            : control.visualPosition * (control.availableHeight - height))
        radius: width / 2
        color: control.pressed ? control.theme.accent : control.theme.surface
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.visualFocus ? control.theme.focus : control.theme.accent
    }
}
