import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.Button {
    id: control
    property Theme theme: Theme {}
    property string variant: "primary"

    readonly property color fillColor: variant === "destructive" ? theme.destructive
        : variant === "primary" ? theme.accent
        : variant === "ghost" && !hovered && !down && !checked ? "transparent"
        : hovered || down || checked ? theme.surfaceHover : theme.surface
    readonly property color labelColor: variant === "destructive" ? theme.destructiveForeground
        : variant === "primary" ? theme.accentForeground : theme.foreground

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    font.weight: Font.Medium
    padding: theme.padding
    verticalPadding: theme.spacing
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    palette.buttonText: labelColor
    palette.brightText: labelColor
    palette.windowText: labelColor
    palette.highlight: labelColor
    // v0.1 renders text (including glyphs); native icon.name/source are not rendered.
    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.labelColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: control.theme.controlHeight * 2
        implicitHeight: control.theme.controlHeight
        radius: control.theme.radius
        color: control.fillColor
        border.width: control.visualFocus ? control.theme.focusWidth
            : control.variant === "secondary" ? control.theme.borderWidth : 0
        border.color: control.visualFocus ? control.theme.focus : control.theme.border

        Rectangle {
            anchors.fill: parent
            anchors.margins: -control.theme.focusWidth - 2
            radius: parent.radius + control.theme.focusWidth + 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: control.visualFocus
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: parent.border.width
            radius: Math.max(0, parent.radius - parent.border.width)
            color: control.labelColor
            opacity: control.down ? 0.14 : control.hovered ? 0.06 : 0
            Behavior on opacity { NumberAnimation { duration: control.theme.motionDuration } }
        }
        Behavior on color { ColorAnimation { duration: control.theme.motionDuration } }
    }
}
