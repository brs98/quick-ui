import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.CheckBox {
    id: control
    property Theme theme: Theme {}

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.spacing / 2
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    implicitHeight: Math.max(theme.controlHeight, implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    indicator: Rectangle {
        id: box
        implicitWidth: Math.max(16, control.theme.controlHeight - control.theme.spacing * 2)
        implicitHeight: implicitWidth
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding)
            : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: Math.min(height / 4, control.theme.radius)
        color: control.checkState !== Qt.Unchecked ? control.theme.accent
            : control.hovered ? control.theme.surfaceHover : control.theme.surface
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.visualFocus ? control.theme.focus : control.theme.border

        // Geometric marks stay sharp without depending on a font's glyph coverage.
        Item {
            anchors.centerIn: parent
            width: box.width * 0.48
            height: box.height * 0.32
            rotation: -45
            visible: control.checkState === Qt.Checked
            Rectangle {
                width: Math.max(2, box.width * 0.09)
                height: parent.height
                color: control.theme.accentForeground
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.max(2, box.width * 0.09)
                color: control.theme.accentForeground
            }
        }
        Rectangle {
            anchors.centerIn: parent
            width: box.width * 0.5
            height: Math.max(2, box.width * 0.09)
            color: control.theme.accentForeground
            visible: control.checkState === Qt.PartiallyChecked
        }
        Behavior on color { ColorAnimation { duration: control.theme.motionDuration } }
    }

    contentItem: Text {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.theme.foreground
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
