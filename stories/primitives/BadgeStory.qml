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
    UI.Badge {
        id: control
        anchors.fill: parent
        theme: tokens
        text: root.args.text ?? "Connected"
        variant: root.args.variant ?? "accent"
        statusDot: root.args.decoration === "dot"
        busy: root.args.decoration === "busy"
        icon.source: root.args.decoration === "icon" ? Qt.resolvedUrl("assets/add.svg") : ""
    }
}
