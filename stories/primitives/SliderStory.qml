import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property real localValue: root.args.value ?? 60
    property bool interactionChanged: false
    signal eventRaised(string name, var payload)
    implicitWidth: args.vertical === true ? control.implicitWidth : 300
    implicitHeight: args.vertical === true ? 220 : control.implicitHeight
    function commit() {
        if (!interactionChanged) return;
        interactionChanged = false;
        eventRaised("valueCommitted", {value: control.value});
    }
    UI.Theme { id: tokens; dark: root.dark }
    UI.Slider {
        id: control
        anchors.fill: parent
        theme: tokens
        from: 0; to: 100; stepSize: root.args.step ?? 1
        orientation: root.args.vertical === true ? Qt.Vertical : Qt.Horizontal
        LayoutMirroring.enabled: root.args.rtl === true
        snapMode: root.args.snap === true ? UI.Slider.SnapAlways : UI.Slider.NoSnap
        live: root.args.releaseOnly !== true
        value: root.localValue
        enabled: root.args.disabled !== true
        Accessible.name: "Volume"
        onMoved: {
            root.localValue = value;
            root.interactionChanged = true;
            root.eventRaised("moved", {value: value});
            if (!pressed) root.commit();
        }
        onPressedChanged: if (!pressed) Qt.callLater(root.commit)
    }
    onArgsChanged: { localValue = args.value ?? 60; interactionChanged = false; }
}
