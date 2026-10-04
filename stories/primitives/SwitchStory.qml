import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool localChecked: root.args.checked === true
    signal eventRaised(string name, var payload)
    implicitWidth: control.implicitWidth
    implicitHeight: control.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.Switch {
        id: control
        anchors.fill: parent
        theme: tokens
        text: root.args.text ?? "Do not disturb"
        checked: root.localChecked
        enabled: root.args.disabled !== true
        onToggled: { root.localChecked = checked; root.eventRaised("toggled", {checked: checked}); }
    }
    onArgsChanged: localChecked = args.checked === true
}
