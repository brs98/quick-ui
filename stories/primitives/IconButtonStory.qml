import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: control.implicitWidth
    implicitHeight: control.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.IconButton {
        id: control
        anchors.fill: parent
        theme: tokens
        text: root.args.icon ?? "+"
        accessibleLabel: root.args.label ?? "Add workspace"
        variant: root.args.variant ?? "secondary"
        enabled: root.args.disabled !== true
        onClicked: root.eventRaised("clicked", {action: accessibleLabel})
    }
}
