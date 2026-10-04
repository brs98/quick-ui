import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool localCurrent: args.current === true
    property alias control: device
    signal eventRaised(string name, var payload)
    implicitWidth: 350
    implicitHeight: device.implicitHeight
    onArgsChanged: localCurrent = args.current === true
    UI.Theme { id: tokens; dark: root.dark }
    UI.DeviceItem {
        id: device
        anchors.fill: parent
        theme: tokens
        text: root.args.text ?? "Speakers"
        glyph: root.args.glyph ?? "♫"
        current: root.localCurrent
        enabled: root.args.disabled !== true
        onClicked: { root.localCurrent = !root.localCurrent; root.eventRaised("selected", {current: root.localCurrent}); }
    }
}
