import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.Slider {
    id: control
    property Theme theme: Theme {}

    padding: theme.spacing
    implicitWidth: horizontal ? 200 : Math.max(theme.controlHeight, theme.handleSize + leftPadding + rightPadding)
    implicitHeight: horizontal ? Math.max(theme.controlHeight, theme.handleSize + topPadding + bottomPadding) : 200
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
            color: control.theme.primary
        }
    }

    handle: Rectangle {
        id: thumb
        implicitWidth: control.theme.handleSize
        implicitHeight: implicitWidth
        x: control.leftPadding + (control.horizontal
            ? control.visualPosition * (control.availableWidth - width)
            : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal
            ? (control.availableHeight - height) / 2
            : control.visualPosition * (control.availableHeight - height))
        radius: width / 2
        color: control.pressed ? control.theme.primary : control.theme.surface
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.visualFocus ? control.theme.focus : control.theme.primary
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: width / 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: control.visualFocus
        }
    }
}
