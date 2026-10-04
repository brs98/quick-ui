import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property int localIndex: root.args.index ?? 0
    signal eventRaised(string name, var payload)
    implicitWidth: 260
    implicitHeight: control.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.Select {
        id: control
        anchors.fill: parent
        theme: tokens
        model: ["Speakers", "Headphones", "HDMI output"]
        currentIndex: root.localIndex
        enabled: root.args.disabled !== true
        Accessible.name: "Audio output"
        onActivated: { root.localIndex = currentIndex; root.eventRaised("activated", {index: currentIndex, text: currentText}); }
    }
    onArgsChanged: localIndex = args.index ?? 0
}
