pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.ComboBox {
    id: control
    property Theme theme: Theme {}

    implicitWidth: 200
    implicitHeight: Math.max(theme.controlHeight, implicitContentHeight + topPadding + bottomPadding)
    padding: theme.padding
    topPadding: 0
    bottomPadding: 0
    spacing: theme.spacing
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    opacity: enabled ? 1 : theme.disabledOpacity
    hoverEnabled: true

    // Keep the native editable field and selection behavior, with semantic colors.
    palette.text: theme.foreground
    palette.buttonText: theme.foreground
    palette.base: theme.surface
    palette.button: theme.surface
    palette.window: theme.surface
    palette.highlight: theme.accent
    palette.highlightedText: theme.accentForeground
    palette.dark: theme.foreground
    palette.mid: theme.border

    indicator: Text {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: (control.height - height) / 2
        text: "⌄"
        color: control.theme.mutedForeground
        font: control.font
    }

    background: Rectangle {
        color: control.down || control.hovered ? control.theme.surfaceHover : control.theme.surface
        radius: control.theme.radius
        border.color: control.visualFocus ? control.theme.focus : control.theme.border
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
    }

    delegate: Controls.ItemDelegate {
        id: option
        required property int index
        required property var model
        width: control.popup.availableWidth
        implicitHeight: control.theme.controlHeight
        text: model[control.textRole]
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        padding: control.theme.padding
        font: control.font
        contentItem: Text {
            text: option.text
            textFormat: Text.PlainText
            font.family: option.font.family
            font.pixelSize: option.font.pixelSize
            font.weight: option.index === control.currentIndex ? Font.DemiBold : Font.Normal
            color: option.highlighted ? control.theme.accentForeground : control.theme.foreground
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: Math.max(0, control.theme.radius - 2)
            color: option.highlighted ? control.theme.accent
                : option.hovered ? control.theme.surfaceHover : "transparent"
        }
    }

    popup: Controls.Popup {
        y: control.height + control.theme.spacing / 2
        width: control.width
        implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 280)
        padding: 4
        topMargin: control.theme.spacing
        bottomMargin: control.theme.spacing
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollBar.vertical: Controls.ScrollBar {
                id: scrollBar
                contentItem: Rectangle {
                    implicitWidth: 4
                    implicitHeight: 24
                    radius: 2
                    color: scrollBar.pressed ? control.theme.accent : control.theme.mutedForeground
                    opacity: scrollBar.size < 1 ? 1 : 0
                }
                background: Rectangle { color: "transparent" }
            }
        }
        background: Rectangle {
            color: control.theme.surface
            radius: control.theme.radius
            border.width: control.theme.borderWidth
            border.color: control.theme.border
        }
    }
}
