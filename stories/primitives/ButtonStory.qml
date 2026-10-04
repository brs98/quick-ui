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
    UI.Button {
        id: control
        anchors.fill: parent
        theme: tokens
        text: root.args.text ?? "Save changes"
        variant: root.args.variant ?? "primary"
        size: root.args.size ?? "default"
        loading: root.args.loading === true
        icon.source: (root.args.iconKind ?? "none") !== "none" ? Qt.resolvedUrl("assets/add.svg") : ""
        icon.name: root.args.iconKind === "theme" ? "list-add" : ""
        iconPosition: root.args.iconPosition ?? "leading"
        display: root.args.display === "under" ? UI.Button.TextUnderIcon
            : root.args.display === "icon" ? UI.Button.IconOnly
            : root.args.display === "text" ? UI.Button.TextOnly : UI.Button.TextBesideIcon
        // Keep text and icon unchanged while loading so the layout stays stable.
        // Guard requests while loading, preserving keyboard focus on this action.
        enabled: root.args.disabled !== true
        onClicked: {
            if (!loading) root.eventRaised("clicked", {text: text})
        }
    }
}
