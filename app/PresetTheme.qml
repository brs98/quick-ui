import QtQuick
import "../registry/quickui" as UI
import "PresetCodec.js" as Codec

UI.Theme {
    id: root
    property var config: Codec.defaults()
    property UI.Theme systemTheme: null
    readonly property var tokens: Codec.resolve(config, dark)
    readonly property bool followsHost: config.colorSource === "system" && systemTheme !== null
    function colorToken(name) { return followsHost ? systemTheme[name] : tokens[name]; }
    background: colorToken("background")
    surface: colorToken("surface")
    surfaceHover: colorToken("surfaceHover")
    foreground: colorToken("foreground")
    mutedForeground: colorToken("mutedForeground")
    border: colorToken("border")
    accent: colorToken("accent")
    accentForeground: colorToken("accentForeground")
    destructive: colorToken("destructive")
    destructiveForeground: colorToken("destructiveForeground")
    focus: colorToken("focus")
    primary: colorToken("primary")
    primaryForeground: colorToken("primaryForeground")
    selection: colorToken("selection")
    selectionForeground: colorToken("selectionForeground")
    popup: colorToken("popup")
    popupForeground: colorToken("popupForeground")
    card: colorToken("card")
    cardForeground: colorToken("cardForeground")
    fontFamily: tokens.fontFamily
    fontScale: tokens.fontScale
    fontSize: tokens.fontSize
    smallFontSize: tokens.smallFontSize
    density: tokens.density
    radius: tokens.radius
    radiusSmall: tokens.radiusSmall
    radiusLarge: tokens.radiusLarge
    controlHeight: tokens.controlHeight
    padding: tokens.padding
    spacing: tokens.spacing
    handleSize: tokens.handleSize
    borderWidth: tokens.borderWidth
    focusWidth: tokens.focusWidth
    motionDuration: tokens.motionDuration
    disabledOpacity: tokens.disabledOpacity
}
