import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property real localValue: root.args.value ?? 60
    signal eventRaised(string name, var payload)
    implicitWidth: 300
    implicitHeight: control.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.Slider {
        id: control
        anchors.fill: parent
        theme: tokens
        from: 0; to: 100; stepSize: 1
        value: root.localValue
        enabled: root.args.disabled !== true
        Accessible.name: "Volume"
        onMoved: { root.localValue = value; root.eventRaised("moved", {value: value}); }
    }
    onArgsChanged: localValue = args.value ?? 60
}
