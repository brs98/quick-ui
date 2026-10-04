import QtQuick

Rectangle {
    property Theme theme: Theme {}
    property bool vertical: false
    implicitWidth: vertical ? theme.borderWidth : 100
    implicitHeight: vertical ? 100 : theme.borderWidth
    color: theme.border
    opacity: enabled ? 1 : theme.disabledOpacity
}
