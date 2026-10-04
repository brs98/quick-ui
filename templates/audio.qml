import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "ui" as UI

// Install audio-mixer, then copy this file to shell.qml. This adapter owns
// mock state; connect the same signals to your audio service in a real shell.
ShellRoot {
    id: root
    property real outputVolume: 0.64
    property real inputVolume: 0.72
    property bool outputMuted: false
    property bool inputMuted: false
    property bool dismissed: false
    property int lastPanelDirection: 0
    property var outputs: [
        {id: "speakers", label: "Studio speakers", glyph: "♪", current: true},
        {id: "headphones", label: "USB headphones", glyph: "♪", current: false}
    ]
    property var inputs: [
        {id: "microphone", label: "USB microphone", glyph: "●", current: true},
        {id: "webcam", label: "Webcam microphone", glyph: "●", current: false}
    ]
    property var streams: [
        {id: "music", label: "Music player", volume: 0.80, muted: false, current: true},
        {id: "browser", label: "Browser", volume: 0.45, muted: true, current: false}
    ]
    UI.Theme { id: tokens }

    function selectDevice(devices, id) {
        if (!devices.some(device => device.id === id)) return devices;
        return devices.map(device => Object.assign({}, device, {current: device.id === id}));
    }
    function updateStream(id, changes) {
        streams = streams.map(stream => stream.id === id ? Object.assign({}, stream, changes) : stream);
    }

    FloatingWindow {
        id: window
        title: "QuickUI — Audio mixer"
        implicitWidth: 460
        implicitHeight: 720
        minimumSize: Qt.size(360, 420)
        color: tokens.background
        Rectangle {
            id: page
            anchors.fill: parent
            color: tokens.background
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "QUICKUI / AUDIO"
                        color: tokens.accent
                        font.family: tokens.fontFamily
                        font.pixelSize: 11
                        font.letterSpacing: 1.5
                    }
                    UI.Button {
                        theme: tokens
                        text: tokens.dark ? "Light theme" : "Dark theme"
                        variant: "secondary"
                        onClicked: tokens.dark = !tokens.dark
                    }
                }
                UI.AudioMixer {
                    id: mixer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    theme: tokens
                    panelNavigation: true
                    outputs: root.outputs
                    inputs: root.inputs
                    streams: root.streams
                    hasOutput: root.outputs.length > 0
                    hasInput: root.inputs.length > 0
                    outputVolume: root.outputVolume
                    inputVolume: root.inputVolume
                    outputMuted: root.outputMuted
                    inputMuted: root.inputMuted
                    inputPeak: root.inputMuted ? 0 : 0.32
                    statusText: "Local mock audio — no services required"
                    onOutputVolumeRequested: value => root.outputVolume = value
                    onInputVolumeRequested: value => root.inputVolume = value
                    onOutputMuteRequested: root.outputMuted = !root.outputMuted
                    onInputMuteRequested: root.inputMuted = !root.inputMuted
                    onAllMuteRequested: {
                        const mute = !root.outputMuted || !root.inputMuted;
                        root.outputMuted = mute;
                        root.inputMuted = mute;
                    }
                    onOutputSelected: id => root.outputs = root.selectDevice(root.outputs, id)
                    onInputSelected: id => root.inputs = root.selectDevice(root.inputs, id)
                    onStreamVolumeRequested: (id, value) => root.updateStream(id, {volume: value})
                    onStreamMuteRequested: id => {
                        const stream = root.streams.find(item => item.id === id);
                        if (stream) root.updateStream(id, {muted: !stream.muted});
                    }
                    onCloseRequested: root.dismissed = true
                    onPanelSwitchRequested: direction => root.lastPanelDirection = direction
                    Component.onCompleted: reset()
                }
                Text {
                    Layout.fillWidth: true
                    text: root.dismissed ? "Dismiss requested — this demo stays open." : "↑↓ / j k navigate · ←→ / h l adjust · m mute · Esc dismiss"
                    wrapMode: Text.WordWrap
                    color: tokens.mutedForeground
                    font.family: tokens.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }
    Connections { target: Quickshell; function onLastWindowClosed() { Qt.quit(); } }

    // Optional integration-test interface. Requests travel through the same
    // component signals as pointer/keyboard input before reaching this adapter.
    IpcHandler {
        target: "quickui-audio-demo"
        function status(): string {
            return JSON.stringify({dark: tokens.dark, accent: tokens.accent.toString(),
                outputVolume: root.outputVolume, inputVolume: root.inputVolume,
                outputMuted: root.outputMuted, inputMuted: root.inputMuted,
                outputs: root.outputs, inputs: root.inputs, streams: root.streams,
                currentOutput: root.outputs.find(device => device.current)?.id || "",
                currentInput: root.inputs.find(device => device.current)?.id || "",
                dismissed: root.dismissed, lastPanelDirection: root.lastPanelDirection,
                width: page.width, height: page.height});
        }
        function theme(dark: bool): void { tokens.dark = dark; }
        function request(action: string, id: string, value: real): bool {
            switch (action) {
            case "output-volume": mixer.outputVolumeRequested(value); break;
            case "input-volume": mixer.inputVolumeRequested(value); break;
            case "output-mute": mixer.outputMuteRequested(); break;
            case "input-mute": mixer.inputMuteRequested(); break;
            case "all-mute": mixer.allMuteRequested(); break;
            case "output-select": mixer.outputSelected(id); break;
            case "input-select": mixer.inputSelected(id); break;
            case "stream-volume": mixer.streamVolumeRequested(id, value); break;
            case "stream-mute": mixer.streamMuteRequested(id); break;
            case "close": mixer.closeRequested(); break;
            case "panel-switch": mixer.panelSwitchRequested(value < 0 ? -1 : 1); break;
            default: return false;
            }
            return true;
        }
        function capture(path: string): bool {
            return page.grabToImage(result => {
                if (!result.saveToFile(path)) console.error("Could not save audio demo capture");
            });
        }
    }
}
