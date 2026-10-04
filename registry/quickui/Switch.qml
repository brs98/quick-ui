import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.Switch {
    id: control
    property Theme theme: Theme {}

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.spacing / 2
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    implicitHeight: Math.max(theme.controlHeight, implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    indicator: Rectangle {
        id: track
        implicitHeight: Math.max(16, control.theme.controlHeight - control.theme.spacing)
        implicitWidth: implicitHeight * 1.7
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding)
            : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: Math.min(height / 2, control.theme.radius * 2)
        color: control.checked ? control.theme.accent
            : control.hovered ? control.theme.surfaceHover : control.theme.surface
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.visualFocus ? control.theme.focus : control.theme.border

        Rectangle {
            readonly property real inset: Math.max(3, control.theme.borderWidth + 1)
            x: inset + control.visualPosition * (track.width - width - inset * 2)
            y: (track.height - height) / 2
            width: height
            height: track.height - inset * 2
            radius: Math.min(height / 2, control.theme.radius)
            color: control.checked ? control.theme.accentForeground : control.theme.foreground
            Behavior on x {
                enabled: !control.down
                NumberAnimation { duration: control.theme.motionDuration; easing.type: Easing.OutCubic }
            }
        }
        Behavior on color { ColorAnimation { duration: control.theme.motionDuration } }
    }

    contentItem: Text {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.theme.foreground
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
