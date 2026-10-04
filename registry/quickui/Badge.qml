import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.Label {
    id: control
    property Theme theme: Theme {}
    property string variant: "neutral"
    textFormat: Text.PlainText
    leftPadding: theme.spacing
    rightPadding: theme.spacing
    topPadding: 3
    bottomPadding: 3
    font.family: theme.fontFamily
    font.pixelSize: theme.smallFontSize
    font.weight: Font.DemiBold
    color: variant === "accent" ? theme.accentForeground
        : variant === "destructive" ? theme.destructiveForeground : theme.foreground
    opacity: enabled ? 1 : theme.disabledOpacity
    background: Rectangle {
        radius: height / 2
        color: control.variant === "accent" ? control.theme.accent
            : control.variant === "destructive" ? control.theme.destructive : control.theme.surfaceHover
    }
}
