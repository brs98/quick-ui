import QtQuick
import "../examples"

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property real localVolume: args.volume === undefined ? 64 : Number(args.volume)
    property bool localMuted: args.muted === true
    signal eventRaised(string name, var payload)
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    VolumeCard {
        id: card
        anchors.fill: parent
        dark: root.dark
        deviceName: root.args.deviceName === undefined ? "Studio speakers" : root.args.deviceName
        volume: root.localVolume
        muted: root.localMuted
        onVolumeRequested: value => {
            root.localVolume = value;
            root.eventRaised("volumeRequested", { volume: Math.round(value) });
        }
        onMuteRequested: value => {
            root.localMuted = value;
            root.eventRaised("muteRequested", { muted: value });
        }
    }
    onArgsChanged: {
        localVolume = args.volume === undefined ? 64 : Number(args.volume);
        localMuted = args.muted === true;
    }
}
