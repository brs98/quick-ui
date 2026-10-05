import QtQuick
import QtQuick.Controls.Basic as Controls

// Native MenuSeparator stays outside the menu's keyboard selection sequence.
Controls.MenuSeparator {
    id: control
    property Theme theme: Theme {}
    property string size: "default"
    horizontalPadding: theme.paddingFor(size)
    verticalPadding: theme.spacing / 2
    contentItem: Rectangle {
        implicitWidth: 160
        implicitHeight: Math.max(1, control.theme.borderWidth)
        color: control.theme.border
    }
}
