import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    id: root

    property bool dark: true
    property string deviceName: "Studio speakers"
    property real volume: 64
    property bool muted: false
    signal volumeRequested(real value)
    signal muteRequested(bool value)

    implicitWidth: 360
    implicitHeight: 212
    radius: 20
    color: dark ? "#222335" : "#ffffff"
    border.color: dark ? "#38394d" : "#e2deed"

    Text {
        x: 24; y: 22
        text: "OUTPUT DEVICE"
        font.pixelSize: 10
        font.weight: Font.Bold
        font.letterSpacing: 1.5
        color: root.dark ? "#9293ad" : "#787287"
    }
    Text {
        x: 24; y: 45
        width: parent.width - 102
        elide: Text.ElideRight
        text: root.deviceName
        font.pixelSize: 20
        font.weight: Font.DemiBold
        color: root.dark ? "#f2effb" : "#29243c"
    }
    Text {
        x: 24; y: 76
        text: root.muted ? "Sound is muted" : "Your space. Your soundtrack."
        font.pixelSize: 12
        color: root.dark ? "#a4a3bb" : "#777185"
    }
    Rectangle {
        anchors.right: parent.right; anchors.rightMargin: 24
        y: 28; width: 38; height: 38; radius: 12
        color: root.dark ? "#353047" : "#eee8fc"
        Text {
            anchors.centerIn: parent
            text: root.muted ? "×" : "♪"
            color: root.dark ? "#bfaaff" : "#8266c8"
            font.pixelSize: 24
        }
    }
    Slider {
        id: slider
        x: 24; y: 107; width: parent.width - 48; height: 32
        from: 0; to: 100; stepSize: 1
        value: root.volume
        onMoved: root.volumeRequested(value)
        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth; height: 6; radius: 3
            color: root.dark ? "#3b3a50" : "#e8e3f0"
            Rectangle {
                width: parent.width * slider.visualPosition; height: parent.height; radius: 3
                color: root.muted ? (root.dark ? "#686477" : "#b9b1c6") : "#b4a0ff"
            }
        }
        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: 18; height: 18; radius: 9
            color: slider.pressed ? "#ffffff" : "#e9e0ff"
            border.width: slider.activeFocus ? 3 : 2
            border.color: "#b4a0ff"
        }
    }
    Text {
        x: 24; y: 161
        text: Math.round(root.volume) + "%"
        font.pixelSize: 20
        font.weight: Font.DemiBold
        color: root.dark ? "#efecf8" : "#302a41"
    }
    ActionButton {
        anchors.right: parent.right; anchors.rightMargin: 24
        y: 152; width: 102; height: 36
        text: root.muted ? "Unmute" : "Mute"
        tone: "secondary"
        dark: root.dark
        onClicked: root.muteRequested(!root.muted)
    }
}
