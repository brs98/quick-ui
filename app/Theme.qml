import QtQuick
import "../registry/quickui" as UI

// Explorer chrome uses the same tokens and controls as the preview library.
UI.Theme {
    controlHeight: 34
    fontSize: 12
    smallFontSize: 11
    radius: 7
    readonly property color bg: background
    readonly property color panel: surface
    readonly property color raised: surfaceHover
    readonly property color line: border
    readonly property color text: foreground
    readonly property color muted: mutedForeground
    readonly property color selected: dark ? "#343047" : "#eee8ff"
    readonly property color green: dark ? "#8ddab5" : "#287d58"
}
