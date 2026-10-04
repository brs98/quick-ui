import QtQuick

// Pass one shared Theme to your components. Edit this copied source freely.
QtObject {
    property bool dark: true
    property color background: dark ? "#14151c" : "#f4f3f8"
    property color surface: dark ? "#1b1c25" : "#ffffff"
    property color surfaceHover: dark ? "#292b38" : "#eeedf5"
    property color foreground: dark ? "#eeedf5" : "#242334"
    property color mutedForeground: dark ? "#9799ad" : "#717084"
    property color border: dark ? "#3a3c4b" : "#d5d3e1"
    property color accent: dark ? "#b4a0ff" : "#7152cf"
    property color accentForeground: dark ? "#211a36" : "#ffffff"
    property color destructive: dark ? "#f08095" : "#ba2948"
    property color destructiveForeground: dark ? "#211a36" : "#ffffff"
    property color focus: accent
    property string fontFamily: "sans-serif"
    property int fontSize: 13
    property int smallFontSize: 11
    property int radius: 8
    property int controlHeight: 36
    property int padding: 12
    property int spacing: 8
    property int borderWidth: 1
    property int focusWidth: 2
    property int motionDuration: 120
    property real disabledOpacity: 0.45
}
