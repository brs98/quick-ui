import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property string localText: root.args.text ?? ""
    signal eventRaised(string name, var payload)
    implicitWidth: 300
    implicitHeight: control.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.TextField {
        id: control
        anchors.fill: parent
        theme: tokens
        text: root.localText
        placeholderText: root.args.placeholder ?? "Name your workspace"
        enabled: root.args.disabled !== true
        readOnly: root.args.readOnly === true
        Accessible.name: root.args.label ?? "Workspace name"
        onTextEdited: { root.localText = text; root.eventRaised("textEdited", {text: text}); }
        onAccepted: root.eventRaised("accepted", {text: text})
    }
    onArgsChanged: localText = args.text ?? ""
}
