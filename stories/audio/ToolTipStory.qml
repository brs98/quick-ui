import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property alias control: tip
    signal eventRaised(string name, var payload)
    implicitWidth: 350
    implicitHeight: 150
    UI.Theme { id: tokens; dark: root.dark }
    UI.Button {
        id: trigger
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        theme: tokens
        text: "Hover or focus me"
        variant: "secondary"
        onClicked: root.eventRaised("clicked", {})
        UI.ToolTip {
            id: tip
            theme: tokens
            text: root.args.text ?? "Mute output"
            visible: root.args.show !== false || trigger.hovered || trigger.activeFocus
            delay: 0
            timeout: -1
            y: trigger.height + 8
            width: Math.min(implicitWidth, root.width)
        }
    }
}
