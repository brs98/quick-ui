import QtQuick

Button {
    property string accessibleLabel: text
    Accessible.name: accessibleLabel
    implicitWidth: implicitHeight
    horizontalPadding: theme.spacing
    // Supply a text glyph, with accessibleLabel describing its action.
}
