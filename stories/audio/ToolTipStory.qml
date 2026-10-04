import QtQuick
import QtQuick.Controls.Basic as Controls
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
        Accessible.description: tip.text
        onClicked: root.eventRaised("clicked", {})
        UI.ToolTip {
            id: tip
            theme: tokens
            text: root.args.text ?? "Mute output"
            visible: trigger.hovered || trigger.visualFocus || root.args.show === true
            delay: root.args.show === true ? 0 : 600
            timeout: root.args.show === true ? -1 : 4000
            closePolicy: root.args.show === true ? Controls.Popup.NoAutoClose
                : Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutsideParent | Controls.Popup.CloseOnReleaseOutsideParent
            placement: root.args.placement ?? "bottom"
            offset: 8
            maximumWidth: Math.min(root.args.maximumWidth ?? 320, root.width)
        }
    }
}
