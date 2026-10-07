import QtQuick
import QtQuick.Controls.Basic as Controls
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property alias control: dialog
    property alias trigger: trigger
    property string savedName: "Personal workspace"
    signal eventRaised(string name, var payload)
    implicitWidth: 460
    implicitHeight: 300
    UI.Theme {
        id: tokens
        dark: root.dark
        density: root.args.density ?? "default"
        fontScale: root.args.fontScale ?? 1
        radius: root.args.radius ?? 8
    }
    function reset() {
        dialog.close();
        savedName = root.args.name ?? "Personal workspace";
        workspaceName.text = savedName;
    }
    Component.onCompleted: reset()
    onArgsChanged: reset()
    UI.Button {
        id: trigger
        x: tokens.spacing; y: tokens.spacing
        theme: tokens
        text: "Edit workspace"
        variant: "outline"
        onClicked: { workspaceName.text = root.savedName; dialog.open(); }
    }
    Text {
        anchors.top: trigger.bottom
        anchors.topMargin: tokens.spacing * 2
        x: tokens.spacing
        width: root.width - tokens.spacing * 2
        text: "Saved name: " + root.savedName
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: tokens.mutedForeground
        font.family: tokens.fontFamily
        font.pixelSize: tokens.fontSize
    }
    UI.Dialog {
        id: dialog
        objectName: "storyDialog"
        theme: tokens
        title: root.args.title ?? "Edit workspace"
        standardButtons: Controls.Dialog.Save | Controls.Dialog.Cancel
        contentItem: UI.Field {
            theme: tokens
            label: "Workspace name"
            UI.TextField { id: workspaceName; objectName: "workspaceName"; theme: tokens; width: parent.width }
        }
        onOpened: workspaceName.forceActiveFocus(Qt.TabFocusReason)
        onAccepted: {
            root.savedName = workspaceName.text;
            root.eventRaised("saved", {name: root.savedName});
        }
        onRejected: root.eventRaised("canceled", {})
    }
}
