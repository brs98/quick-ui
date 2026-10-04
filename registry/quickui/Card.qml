import QtQuick
import QtQuick.Controls.Basic as Controls

// Pane reparents default children into contentItem and sizes from their implicit size.
Controls.Pane {
    id: control
    property Theme theme: Theme {}
    padding: theme.padding
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    palette.windowText: theme.foreground
    opacity: enabled ? 1 : theme.disabledOpacity
    background: Rectangle {
        color: control.theme.surface
        radius: control.theme.radius
        border.width: control.theme.borderWidth
        border.color: control.theme.border
    }
}
