import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.ToolTip {
    id: control
    property Theme theme: Theme {}
    // Native x/y and popup edge flipping remain available to callers.
    property real maximumWidth: 320
    property string placement: "top"
    property real offset: theme.spacing / 2
    width: Math.min(implicitWidth, maximumWidth > 0 ? maximumWidth : implicitWidth)
    x: parent ? (parent.width - width) / 2 : 0
    y: placement === "bottom" && parent ? parent.height + offset : -height - offset
    delay: 600
    timeout: 4000
    font.family: theme.fontFamily
    font.pixelSize: theme.smallFontSize
    padding: theme.spacing
    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.theme.popupForeground
        wrapMode: Text.Wrap
    }
    background: Rectangle {
        color: control.theme.popup
        radius: control.theme.radius
        border.color: control.theme.border
        border.width: control.theme.borderWidth
    }
}
