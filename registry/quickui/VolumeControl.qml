import QtQuick

// Controlled component: the owner accepts requests and updates value/muted.
Item {
    id: root
    property Theme theme: Theme {}
    property string title: ""
    property string glyph: "🔊"
    property real value: 0
    property real maximum: 1
    property real stepSize: 0.05
    property bool muted: false
    property bool available: true
    property bool cursorHighlighted: false
    property bool active: false
    property bool showMeter: false
    property real peak: 0
    readonly property real liveValue: dragging ? volumeSlider.value : bounded(value)
    readonly property bool dragging: volumeSlider.pressed
    property alias slider: volumeSlider
    property alias muteButton: muteControl
    signal volumeRequested(real value)
    signal muteRequested()
    signal hovered()

    implicitWidth: 320
    implicitHeight: titleLabel.implicitHeight + theme.spacing + theme.controlHeight + theme.padding * 2 + (showMeter ? 6 + theme.spacing : 0)
    opacity: available && enabled ? 1 : theme.disabledOpacity

    function bounded(input: real): real {
        return Number.isFinite(input) ? Math.max(0, Math.min(Math.max(0, maximum), input)) : 0;
    }
    function syncSlider(): void {
        if (!volumeSlider.pressed) volumeSlider.value = Qt.binding(function() { return root.bounded(root.value); });
    }

    Rectangle {
        anchors.fill: parent
        color: root.theme.surface
        radius: root.theme.radius
        border.width: root.cursorHighlighted ? root.theme.focusWidth : root.theme.borderWidth
        border.color: root.cursorHighlighted ? root.theme.focus : root.theme.border
    }
    HoverHandler { onHoveredChanged: if (hovered) root.hovered() }
    Text {
        id: titleLabel
        x: root.theme.padding
        y: root.theme.padding
        width: Math.max(0, root.width - root.theme.padding * 2 - percentLabel.width - root.theme.spacing)
        text: root.title
        textFormat: Text.PlainText
        elide: Text.ElideRight
        color: root.active ? root.theme.accent : root.theme.foreground
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
        font.weight: Font.Medium
    }
    Text {
        id: percentLabel
        anchors.right: parent.right
        anchors.rightMargin: root.theme.padding
        y: titleLabel.y
        text: root.available ? Math.round(root.liveValue * 100) + "%" : qsTr("Unavailable")
        color: root.theme.mutedForeground
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.smallFontSize
    }
    IconButton {
        id: muteControl
        x: root.theme.padding
        y: titleLabel.y + titleLabel.implicitHeight + root.theme.spacing
        theme: root.theme
        enabled: root.available
        variant: "ghost"
        text: root.muted ? "×" : root.glyph
        accessibleLabel: (root.muted ? qsTr("Unmute") : qsTr("Mute")) + (root.title ? " " + root.title : "")
        onClicked: root.muteRequested()
        ToolTip {
            theme: root.theme
            text: muteControl.accessibleLabel
            visible: muteControl.enabled && (muteControl.hovered || muteControl.visualFocus)
        }
    }
    Slider {
        id: volumeSlider
        x: muteControl.x + muteControl.width + root.theme.spacing
        y: muteControl.y
        width: Math.max(0, root.width - x - root.theme.padding)
        theme: root.theme
        enabled: root.available && root.maximum > 0
        from: 0
        to: Math.max(0, root.maximum)
        stepSize: Math.max(0, root.stepSize)
        value: root.bounded(root.value)
        Accessible.name: root.title ? root.title + " " + qsTr("volume") : qsTr("Volume")
        onMoved: {
            root.volumeRequested(root.bounded(value));
            if (!pressed) root.syncSlider();
        }
        onPressedChanged: if (!pressed) root.syncSlider()
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            enabled: volumeSlider.enabled
            property real wheelRemainder: 0
            onClicked: root.muteRequested()
            onWheel: event => {
                const delta = event.angleDelta.y !== 0 ? event.angleDelta.y / 120 : event.pixelDelta.y / 40;
                wheelRemainder += delta;
                const steps = Math.trunc(wheelRemainder);
                if (steps !== 0) {
                    wheelRemainder -= steps;
                    root.volumeRequested(root.bounded(root.liveValue + steps * Math.max(0, root.stepSize)));
                }
                event.accepted = true;
            }
        }
    }
    LevelMeter {
        visible: root.showMeter
        x: volumeSlider.x + volumeSlider.leftPadding
        y: volumeSlider.y + volumeSlider.height + root.theme.spacing
        width: Math.max(0, volumeSlider.width - volumeSlider.leftPadding - volumeSlider.rightPadding)
        theme: root.theme
        value: root.peak
        muted: root.muted
    }
}
