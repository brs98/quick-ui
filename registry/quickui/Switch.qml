import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.Switch {
    id: control
    property Theme theme: Theme {}
    property string size: "default"
    property string description: ""
    property bool multiline: false
    property bool invalid: false
    Accessible.description: description

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.spacing / 2
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    implicitHeight: Math.max(theme.heightFor(control.size), implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    indicator: Rectangle {
        id: track
        implicitHeight: Math.max(16, control.theme.heightFor(control.size) - control.theme.spacing)
        implicitWidth: implicitHeight * 1.7
        x: control.text || control.description ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding)
            : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: Math.min(height / 2, control.theme.radius * 2)
        color: control.checked ? control.theme.primary
            : control.hovered ? control.theme.surfaceHover : control.theme.surface
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.invalid ? control.theme.destructive : control.visualFocus ? control.theme.focus : control.theme.border

        Rectangle {
            readonly property real inset: Math.max(3, control.theme.borderWidth + 1)
            x: inset + control.visualPosition * (track.width - width - inset * 2)
            y: (track.height - height) / 2
            width: height
            height: track.height - inset * 2
            // Offset the outer contour so the track and thumb corners are concentric.
            radius: Math.max(0, Math.min(height / 2, track.radius - inset))
            color: control.checked ? control.theme.primaryForeground : control.theme.foreground
            Behavior on x {
                enabled: !control.down
                NumberAnimation { duration: control.theme.motionDuration; easing.type: Easing.OutCubic }
            }
        }
        Rectangle {
            objectName: "focusRing"
            anchors.fill: parent
            anchors.margins: -(control.theme.focusWidth + 2)
            radius: track.radius + control.theme.focusWidth + 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: control.visualFocus
        }
        Behavior on color { ColorAnimation { duration: control.theme.motionDuration } }
    }

    contentItem: Item {
        implicitWidth: Math.max(title.implicitWidth, detail.implicitWidth) + control.indicator.width + control.spacing
        implicitHeight: labels.implicitHeight
        Column {
            id: labels
            x: control.mirrored ? 0 : control.indicator.width + control.spacing
            width: Math.max(0, parent.width - control.indicator.width - control.spacing)
            anchors.verticalCenter: parent.verticalCenter
            spacing: control.description ? control.theme.spacing / 2 : 0
            Text {
                id: title
                objectName: "toggleLabel"
                width: parent.width
                text: control.text
                textFormat: Text.PlainText
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                font: control.font
                color: control.theme.foreground
                wrapMode: control.multiline ? Text.Wrap : Text.NoWrap
                elide: control.multiline ? Text.ElideNone : Text.ElideRight
            }
            Text {
                id: detail
                visible: text.length > 0
                width: parent.width
                text: control.description
                textFormat: Text.PlainText
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                font.family: control.theme.fontFamily
                font.pixelSize: control.theme.smallFontSize
                color: control.theme.mutedForeground
                wrapMode: Text.Wrap
            }
        }
    }
}
