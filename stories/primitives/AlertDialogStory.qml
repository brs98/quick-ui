import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property alias control: dialog
    property alias trigger: trigger
    property string lastAction: "No action requested"
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
    function reset() { dialog.close(); lastAction = "No action requested"; }
    Component.onCompleted: reset()
    onArgsChanged: reset()
    UI.Button {
        id: trigger
        x: tokens.spacing; y: tokens.spacing
        theme: tokens
        variant: "outline"
        text: "Show confirmation"
        onClicked: dialog.open()
    }
    Text {
        anchors.top: trigger.bottom
        anchors.topMargin: tokens.spacing * 2
        x: tokens.spacing
        width: root.width - tokens.spacing * 2
        text: root.lastAction
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: tokens.mutedForeground
        font.family: tokens.fontFamily
        font.pixelSize: tokens.fontSize
    }
    UI.AlertDialog {
        id: dialog
        objectName: "storyAlertDialog"
        theme: tokens
        title: root.args.title ?? "Remove workspace?"
        description: root.args.description ?? "This example only records an event. No workspace or file is removed."
        confirmText: root.args.confirmText ?? "Remove"
        cancelText: "Keep workspace"
        variant: root.args.variant ?? "destructive"
        confirmEnabled: root.args.disabled !== true
        onAccepted: {
            root.lastAction = "Removal requested";
            root.eventRaised("confirmed", {});
        }
        onRejected: {
            root.lastAction = "Workspace kept";
            root.eventRaised("canceled", {});
        }
    }
}
