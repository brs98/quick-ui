import QtQuick
import QtQuick.Controls.Basic as Controls

// Use one content child (normally a ColumnLayout). Pane derives content size
// from that child; bind its width to availableWidth for wrapping.
Controls.Pane {
    id: control
    property Theme theme: Theme {}
    property string size: "default"
    padding: theme.paddingFor(size)
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    palette.windowText: theme.cardForeground
    opacity: enabled ? 1 : theme.disabledOpacity
    background: Rectangle {
        color: control.theme.card
        radius: control.theme.radiusLarge
        border.width: control.theme.borderWidth
        border.color: control.theme.border
    }
}
