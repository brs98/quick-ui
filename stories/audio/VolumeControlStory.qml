import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property alias control: volume
    property real localValue: args.value ?? 0.6
    property bool localMuted: args.muted === true
    signal eventRaised(string name, var payload)
    LayoutMirroring.enabled: args.rtl === true
    LayoutMirroring.childrenInherit: true
    implicitWidth: 350
    implicitHeight: volume.implicitHeight
    onArgsChanged: { localValue = args.value ?? 0.6; localMuted = args.muted === true; }
    UI.Theme { id: tokens; dark: root.dark; fontScale: root.args.fontScale ?? 1 }
    UI.VolumeControl {
        id: volume
        anchors.fill: parent
        theme: tokens
        title: root.args.title ?? "Output"
        glyph: "♫"
        value: root.localValue
        maximum: root.args.maximum ?? 1
        muted: root.localMuted
        available: root.args.available !== false
        showMeter: root.args.showMeter === true
        peak: root.args.peak ?? 0.4
        onVolumeRequested: function(value) { root.localValue = value; root.eventRaised("volumeRequested", {value: value}); }
        onMuteRequested: { root.localMuted = !root.localMuted; root.eventRaised("muteRequested", {muted: root.localMuted}); }
    }
}
