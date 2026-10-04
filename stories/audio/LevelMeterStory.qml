import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property alias control: meter
    signal eventRaised(string name, var payload)
    implicitWidth: 350
    implicitHeight: 52
    UI.Theme { id: tokens; dark: root.dark }
    Text {
        anchors.top: parent.top
        text: "Input level · " + Math.round(meter.boundedValue * 100) + "%"
        color: tokens.foreground
        font.family: tokens.fontFamily
        font.pixelSize: tokens.fontSize
    }
    UI.LevelMeter {
        id: meter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        theme: tokens
        value: root.args.value ?? 0.35
        muted: root.args.muted === true
    }
}
