import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool localChecked: root.args.checked === true
    signal eventRaised(string name, var payload)
    implicitWidth: root.args.multiline || root.args.description ? 300 : control.implicitWidth
    implicitHeight: control.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.Switch {
        id: control
        anchors.fill: parent
        theme: tokens
        text: root.args.text ?? "Do not disturb"
        description: root.args.description ?? ""
        multiline: root.args.multiline === true
        invalid: root.args.invalid === true
        size: root.args.size ?? "default"
        checked: root.localChecked
        enabled: root.args.disabled !== true
        onToggled: { root.localChecked = checked; root.eventRaised("toggled", {checked: checked}); }
    }
    onArgsChanged: localChecked = args.checked === true
}
