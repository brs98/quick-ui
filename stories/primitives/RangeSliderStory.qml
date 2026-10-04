import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: args.vertical === true ? range.implicitWidth : 300
    implicitHeight: args.vertical === true ? 240 : range.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.RangeSlider {
        id: range
        anchors.fill: parent
        theme: tokens
        from: 0; to: 100
        stepSize: root.args.step ?? 5
        snapMode: UI.RangeSlider.SnapAlways
        first.value: root.args.minimum ?? 25
        second.value: root.args.maximum ?? 75
        orientation: root.args.vertical === true ? Qt.Vertical : Qt.Horizontal
        LayoutMirroring.enabled: root.args.rtl === true
        enabled: root.args.disabled !== true
        firstAccessibleName: "Minimum brightness"
        secondAccessibleName: "Maximum brightness"
        first.onMoved: root.eventRaised("minimumMoved", {value: first.value})
        second.onMoved: root.eventRaised("maximumMoved", {value: second.value})
    }
    onArgsChanged: range.setValues(args.minimum ?? 25, args.maximum ?? 75)
}
