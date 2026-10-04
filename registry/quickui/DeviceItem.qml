import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.ItemDelegate {
    id: control
    property Theme theme: Theme {}
    property string glyph: ""
    property bool current: false
    property bool cursorHighlighted: false
    implicitWidth: 280
    implicitHeight: Math.max(theme.controlHeight, implicitContentHeight + topPadding + bottomPadding)
    padding: theme.spacing
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    Accessible.name: text
    Accessible.description: current ? qsTr("Current device") : ""
    contentItem: Row {
        spacing: control.spacing
        Text {
            width: visible ? control.font.pixelSize * 1.5 : 0
            visible: control.glyph.length > 0
            text: control.glyph
            textFormat: Text.PlainText
            font: control.font
            color: control.theme.mutedForeground
        }
        Text {
            width: Math.max(0, control.availableWidth - (control.glyph.length ? control.font.pixelSize * 1.5 + control.spacing : 0) - indicator.width - control.spacing)
            text: control.text
            textFormat: Text.PlainText
            font: control.font
            color: control.theme.foreground
            elide: Text.ElideRight
        }
        Text {
            id: indicator
            width: control.font.pixelSize * 1.5
            text: control.current ? "✓" : ""
            font: control.font
            color: control.theme.accent
        }
    }
    background: Rectangle {
        radius: control.theme.radius
        color: control.down || control.hovered || control.current ? control.theme.surfaceHover : control.theme.surface
        border.width: control.visualFocus || control.cursorHighlighted ? control.theme.focusWidth : 0
        border.color: control.theme.focus
    }
}
