import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property alias control: mixer
    property bool initialized: false
    property real localOutputVolume: 0.6
    property real localInputVolume: 0.75
    property bool localOutputMuted: false
    property bool localInputMuted: false
    property var localOutputs: []
    property var localInputs: []
    property var localStreams: []
    signal eventRaised(string name, var payload)
    LayoutMirroring.enabled: args.rtl === true
    LayoutMirroring.childrenInherit: true
    implicitWidth: 400
    implicitHeight: 600

    function resetState() {
        const scenario = args.scenario ?? "Desktop";
        const missing = scenario === "No devices";
        const long = scenario === "Long labels";
        localOutputVolume = args.outputVolume ?? 0.6;
        localInputVolume = args.inputVolume ?? 0.75;
        localOutputMuted = args.muted === true;
        localInputMuted = args.muted === true;
        localOutputs = missing ? [] : [
            {id: "speakers", label: long ? "Studio monitor speakers connected through the external USB audio interface" : "Speakers", glyph: "♫", current: true},
            {id: "headphones", label: "Headphones", glyph: "♪", current: false}
        ];
        localInputs = missing || scenario === "Output only" ? [] : [
            {id: "microphone", label: long ? "External condenser microphone with an exceptionally long device name" : "Microphone", glyph: "●", current: true},
            {id: "headset", label: "Headset microphone", glyph: "●", current: false}
        ];
        localStreams = missing || scenario === "Output only" ? [] : [
            {id: "music", label: long ? "A music player with an exceptionally long application and track title" : "Music", volume: scenario === "Amplified streams" ? 1.3 : 0.85, muted: args.muted === true, current: true},
            {id: "browser", label: "Browser", volume: 0.4, muted: false, current: false}
        ];
        mixer.reset();
    }
    function selectDevice(kind, id) {
        const items = kind === "output" ? localOutputs : localInputs;
        const changed = items.map(item => Object.assign({}, item, {current: item.id === id}));
        if (kind === "output") localOutputs = changed;
        else localInputs = changed;
        eventRaised(kind + "Selected", {id: id});
    }
    function updateStream(id, values) {
        localStreams = localStreams.map(item => item.id === id ? Object.assign({}, item, values) : item);
    }
    onArgsChanged: if (initialized) resetState()
    Component.onCompleted: { initialized = true; resetState(); }
    UI.Theme { id: tokens; dark: root.dark; fontScale: root.args.fontScale ?? 1 }
    UI.AudioMixer {
        id: mixer
        anchors.fill: parent
        theme: tokens
        panelNavigation: root.args.panelNavigation === true
        outputs: root.localOutputs
        inputs: root.localInputs
        streams: root.localStreams
        hasOutput: root.localOutputs.length > 0
        hasInput: root.localInputs.length > 0 && root.args.scenario !== "No default input"
        outputVolume: root.localOutputVolume
        inputVolume: root.localInputVolume
        outputMuted: root.localOutputMuted
        inputMuted: root.localInputMuted
        inputPeak: root.args.peak ?? 0.35
        outputGlyph: "♫"
        statusText: !hasOutput ? "No audio devices" : outputMuted ? "Muted" : "Ready to listen"
        onOutputVolumeRequested: function(value) { root.localOutputVolume = value; root.eventRaised("outputVolumeRequested", {value: value}); }
        onInputVolumeRequested: function(value) { root.localInputVolume = value; root.eventRaised("inputVolumeRequested", {value: value}); }
        onOutputMuteRequested: { root.localOutputMuted = !root.localOutputMuted; root.eventRaised("outputMuteRequested", {muted: root.localOutputMuted}); }
        onInputMuteRequested: { root.localInputMuted = !root.localInputMuted; root.eventRaised("inputMuteRequested", {muted: root.localInputMuted}); }
        onAllMuteRequested: {
            const mute = (hasOutput && !root.localOutputMuted) || (hasInput && !root.localInputMuted);
            root.localOutputMuted = mute;
            root.localInputMuted = mute;
            root.eventRaised("allMuteRequested", {muted: mute});
        }
        onOutputSelected: function(id) { root.selectDevice("output", id); }
        onInputSelected: function(id) { root.selectDevice("input", id); }
        onStreamVolumeRequested: function(id, value) { root.updateStream(id, {volume: value}); root.eventRaised("streamVolumeRequested", {id: id, value: value}); }
        onStreamMuteRequested: function(id) {
            const stream = root.localStreams.find(item => item.id === id);
            if (stream) root.updateStream(id, {muted: !stream.muted});
            root.eventRaised("streamMuteRequested", {id: id});
        }
        onCloseRequested: root.eventRaised("closeRequested", {})
        onPanelSwitchRequested: function(direction) { root.eventRaised("panelSwitchRequested", {direction: direction}); }
    }
}
