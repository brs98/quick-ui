import QtQuick
import QtQuick.Layouts
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: 300
    implicitHeight: field.implicitHeight
    UI.Theme { id: tokens; dark: root.dark; fontScale: root.args.largeText === true ? 1.5 : 1 }
    UI.Field {
        id: field
        anchors.fill: parent
        theme: tokens
        label: root.args.label ?? "Workspace name"
        description: root.args.description ?? "Use a name you can recognize in the switcher."
        errorText: root.args.error ?? ""
        requiredIndicator: root.args.required === true
        UI.TextField {
            id: input
            Layout.fillWidth: true
            theme: tokens
            placeholderText: "Personal"
            enabled: root.args.disabled !== true
            onTextEdited: root.eventRaised("textEdited", {text: text, acceptable: acceptableInput})
        }
    }
    onArgsChanged: input.text = ""
}
