import QtQuick
import "../examples"

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    NotificationCard {
        id: card
        anchors.fill: parent
        dark: root.dark
        title: root.args.title === undefined ? "Your workspace is ready" : root.args.title
        message: root.args.message === undefined ? "Everything is right where you left it. Pick up where you paused." : root.args.message
        sourceName: root.args.sourceName === undefined ? "QUICKBOOK" : root.args.sourceName
        actionLabel: root.args.actionLabel === undefined ? "Open workspace" : root.args.actionLabel
        severity: root.args.severity || "info"
        showAction: root.args.showAction !== false
        onActionRequested: root.eventRaised("actionRequested", { action: actionLabel })
        onDismissRequested: root.eventRaised("dismissRequested", { title: title })
    }
}
