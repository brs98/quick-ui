import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool localChecked: root.args.checked === true
    property bool localPartial: root.args.partial === true
    property alias control: item
    signal eventRaised(string name, var payload)
    implicitWidth: 340
    implicitHeight: card.implicitHeight
    LayoutMirroring.enabled: root.args.rtl === true
    LayoutMirroring.childrenInherit: true
    UI.Theme {
        id: tokens
        dark: root.dark
        density: root.args.density ?? "default"
        fontScale: root.args.fontScale ?? 1
    }
    UI.Card {
        id: card
        theme: tokens
        width: parent.width
        padding: tokens.spacing / 2
        UI.MenuItem {
            id: item
            objectName: "standaloneMenuItem"
            width: card.availableWidth
            theme: tokens
            text: root.args.text ?? "Open workspace"
            shortcutText: root.args.shortcut ?? "Ctrl+O"
            icon.source: root.args.icon === true ? Qt.resolvedUrl("assets/add.svg") : ""
            checkable: root.args.checkable === true
            checked: root.localChecked
            autoExclusive: root.args.indicator === "radio"
            indicatorType: root.args.indicator ?? "auto"
            partiallyChecked: root.localPartial
            enabled: root.args.disabled !== true
            variant: root.args.destructive === true ? "destructive" : "default"
            onTriggered: {
                root.localChecked = checked;
                root.localPartial = false;
                root.eventRaised("triggered", {text: text, checked: checked});
            }
        }
    }
    onArgsChanged: {
        localChecked = args.checked === true;
        localPartial = args.partial === true;
    }
}
