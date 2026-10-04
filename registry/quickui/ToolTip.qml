import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.ToolTip {
    id: control
    property Theme theme: Theme {}
    delay: 600
    timeout: 4000
    font.family: theme.fontFamily
    font.pixelSize: theme.smallFontSize
    padding: theme.spacing
    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.theme.foreground
        wrapMode: Text.Wrap
    }
    background: Rectangle {
        color: control.theme.surface
        radius: control.theme.radius
        border.color: control.theme.border
        border.width: control.theme.borderWidth
    }
}
