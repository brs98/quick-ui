import QtQuick

Button {
    // Always describe the action ("Add workspace"), not its glyph ("+").
    // A consumer may also override Accessible.name directly.
    property string accessibleLabel: text
    Accessible.name: accessibleLabel
    implicitWidth: implicitHeight
    horizontalPadding: theme.spacing
    // Native icons keep text available as the accessible name. Existing glyphs
    // remain the fallback when neither icon.name nor icon.source is supplied.
    display: icon.name.length > 0 || icon.source.toString().length > 0 ? Button.IconOnly : Button.TextOnly
}
