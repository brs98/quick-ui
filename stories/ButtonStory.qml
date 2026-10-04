import QtQuick
import "../examples"

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: 300
    implicitHeight: 130

    ActionButton {
        anchors.centerIn: parent
        text: root.args.label === undefined ? "Create workspace" : root.args.label
        tone: root.args.tone || "primary"
        busy: root.args.busy === true
        enabled: root.args.disabled !== true && !busy
        dark: root.dark
        onClicked: root.eventRaised("clicked", { label: text, tone: tone })
    }
}
