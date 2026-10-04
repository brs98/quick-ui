import QtQuick

// Pass one shared Theme to your components. Edit this copied source freely.
QtObject {
    property bool dark: true
    property color background: dark ? "#14151c" : "#f4f3f8"
    property color surface: dark ? "#1b1c25" : "#ffffff"
    property color surfaceHover: dark ? "#292b38" : "#eeedf5"
    property color foreground: dark ? "#eeedf5" : "#242334"
    property color mutedForeground: dark ? "#9799ad" : "#6b6a7e"
    property color border: dark ? "#3a3c4b" : "#d5d3e1"
    property color accent: dark ? "#b4a0ff" : "#7152cf"
    property color accentForeground: dark ? "#211a36" : "#ffffff"
    property color destructive: dark ? "#f08095" : "#ba2948"
    property color destructiveForeground: dark ? "#211a36" : "#ffffff"
    property color focus: accent
    // Compatible defaults retain existing accent/surface customizations.
    property color primary: accent
    property color primaryForeground: accentForeground
    property color selection: accent
    property color selectionForeground: accentForeground
    property color popup: surface
    property color popupForeground: foreground
    property color card: surface
    property color cardForeground: foreground
    property string fontFamily: "sans-serif"
    property real fontScale: 1
    property string density: "default" // compact, default, comfortable
    property int fontSize: Math.round(13 * fontScale)
    property int smallFontSize: Math.round(11 * fontScale)
    property int radius: 8
    property int radiusSmall: Math.max(0, Math.round(radius * 0.6))
    property int radiusLarge: Math.max(0, Math.round(radius * 1.4))
    property int controlHeight: density === "compact" ? 30 : density === "comfortable" ? 44 : 36
    property int padding: density === "compact" ? 8 : density === "comfortable" ? 16 : 12
    property int spacing: density === "compact" ? 6 : density === "comfortable" ? 10 : 8
    property int handleSize: Math.max(18, Math.round(fontSize * 1.4))
    property int borderWidth: 1
    property int focusWidth: 2
    property int motionDuration: 120
    property real disabledOpacity: 0.45

    function heightFor(size: string): real {
        return size === "sm" ? controlHeight * 5 / 6 : size === "lg" ? controlHeight * 11 / 9 : controlHeight;
    }
    function paddingFor(size: string): real {
        return size === "sm" ? padding * 2 / 3 : size === "lg" ? padding * 4 / 3 : padding;
    }
}
