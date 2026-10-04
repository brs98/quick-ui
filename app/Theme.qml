import QtQuick

QtObject {
    property bool dark: true
    readonly property color bg: dark ? "#14151c" : "#f4f3f8"
    readonly property color panel: dark ? "#1b1c25" : "#ffffff"
    readonly property color raised: dark ? "#252733" : "#eeedf5"
    readonly property color line: dark ? "#30323f" : "#dedde8"
    readonly property color text: dark ? "#eeedf5" : "#242334"
    readonly property color muted: dark ? "#9799ad" : "#717084"
    readonly property color accent: dark ? "#b4a0ff" : "#7152cf"
    readonly property color selected: dark ? "#343047" : "#eee8ff"
    readonly property color green: dark ? "#8ddab5" : "#287d58"
}
