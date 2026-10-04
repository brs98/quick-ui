import QtQuick
import "../registry/quickui" as UI

UI.Card {
    id: root
    property bool dark: true
    property string deviceName: "Studio speakers"
    property real volume: 64
    property bool muted: false
    readonly property real boundedVolume: Number.isFinite(volume) ? Math.max(0, Math.min(100, volume)) : 0
    signal volumeRequested(real value)
    signal muteRequested(bool value)

    implicitWidth: 360
    theme: UI.Theme { dark: root.dark; padding: 24; radiusLarge: 20 }

    function syncSlider(): void {
        if (!slider.pressed) slider.value = Qt.binding(function() { return root.boundedVolume; });
    }

    Column {
        width: root.availableWidth
        spacing: root.theme.spacing
        Item {
            width: parent.width
            implicitHeight: 76
            Text {
                text: qsTr("OUTPUT DEVICE")
                textFormat: Text.PlainText
                font.family: root.theme.fontFamily
                font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1.5
                color: root.theme.mutedForeground
            }
            Text {
                y: 23
                width: Math.max(0, parent.width - 54)
                text: root.deviceName
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.family: root.theme.fontFamily
                font.pixelSize: 20; font.weight: Font.DemiBold
                color: root.theme.cardForeground
            }
            Text {
                y: 54
                width: parent.width
                text: root.muted ? qsTr("Sound is muted") : qsTr("Your space. Your soundtrack.")
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.family: root.theme.fontFamily
                font.pixelSize: 12
                color: root.theme.mutedForeground
            }
            UI.Badge {
                anchors.right: parent.right
                y: 4
                theme: root.theme
                text: root.muted ? "×" : "♪"
                font.pixelSize: 24
                Accessible.ignored: true
            }
        }
        UI.Slider {
            id: slider
            objectName: "exampleVolumeSlider"
            width: parent.width
            theme: root.theme
            from: 0; to: 100; stepSize: 1
            value: root.boundedVolume
            Accessible.name: root.deviceName + qsTr(" volume")
            Accessible.description: Math.round(root.boundedVolume) + "%" + (root.muted ? qsTr(", muted") : "")
            onMoved: {
                root.volumeRequested(value);
                if (!pressed) root.syncSlider();
            }
            onPressedChanged: if (!pressed) root.syncSlider()
        }
        Item {
            width: parent.width
            implicitHeight: muteButton.implicitHeight
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.boundedVolume) + "%"
                textFormat: Text.PlainText
                font.family: root.theme.fontFamily
                font.pixelSize: 20; font.weight: Font.DemiBold
                color: root.theme.cardForeground
            }
            UI.Button {
                id: muteButton
                objectName: "exampleMuteButton"
                anchors.right: parent.right
                theme: root.theme
                text: root.muted ? qsTr("Unmute") : qsTr("Mute")
                variant: "secondary"
                Accessible.name: text + " " + root.deviceName
                onClicked: root.muteRequested(!root.muted)
            }
        }
    }
}
