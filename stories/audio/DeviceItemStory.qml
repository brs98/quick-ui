import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool localCurrent: args.current === true
    property alias control: device
    signal eventRaised(string name, var payload)
    implicitWidth: 350
    implicitHeight: choices.implicitHeight
    LayoutMirroring.enabled: args.rtl === true
    LayoutMirroring.childrenInherit: true
    onArgsChanged: localCurrent = args.current === true
    UI.Theme { id: tokens; dark: root.dark; fontScale: root.args.fontScale ?? 1 }
    Column {
        id: choices
        width: parent.width
        spacing: tokens.spacing
        UI.DeviceItem {
            id: device
            width: parent.width
            theme: tokens
            text: root.args.text ?? "Speakers"
            description: root.args.description ?? ""
            glyph: root.args.glyph ?? "♫"
            current: root.localCurrent
            enabled: root.args.disabled !== true
            // Selection is owner-controlled; choosing the active device does
            // not deselect it. A second row demonstrates exclusive selection.
            onClicked: { root.localCurrent = true; root.eventRaised("selected", {id: "speakers", current: true}); }
        }
        UI.DeviceItem {
            objectName: "storySecondDevice"
            width: parent.width
            visible: root.args.selectionList === true
            theme: tokens
            text: "Headphones"
            description: "USB audio interface"
            glyph: "♪"
            current: !root.localCurrent
            enabled: root.args.disabled !== true
            onClicked: { root.localCurrent = false; root.eventRaised("selected", {id: "headphones", current: true}); }
        }
    }
}
