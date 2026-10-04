import QtQuick
import QtQuick.Controls.Basic as Controls

// Internal visual renderer. The public Button icon API supplies theme lookup,
// source fallback, tint, sizing and caching; it never becomes an input target.
Controls.Button {
    id: graphic
    text: ""
    display: Controls.Button.IconOnly
    enabled: false
    focusPolicy: Qt.NoFocus
    hoverEnabled: false
    Accessible.ignored: true
    padding: 0
    horizontalPadding: 0
    verticalPadding: 0
    implicitWidth: implicitContentWidth
    implicitHeight: implicitContentHeight
    icon.width: 18
    icon.height: 18
    icon.color: "transparent"
    background: null
}
