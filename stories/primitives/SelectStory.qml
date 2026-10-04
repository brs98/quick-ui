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
        model: [
            {label: "Speakers", available: true},
            {label: "Headphones", available: root.args.unavailable !== true},
            {label: "HDMI output", available: true}
        ]
        textRole: "label"
        enabledRole: "available"
        placeholderText: root.args.placeholder ?? "Choose an output"
        invalid: root.args.invalid === true
        editable: root.args.editable === true
        size: root.args.size ?? "default"
        currentIndex: root.localIndex
        enabled: root.args.disabled !== true
        Accessible.name: "Audio output"
        onActivated: { root.localIndex = currentIndex; root.eventRaised("activated", {index: currentIndex, text: currentText}); }
    }
    onArgsChanged: localIndex = args.index ?? 0
}
