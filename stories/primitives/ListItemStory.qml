pragma ComponentBehavior: Bound
import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool localSelected: false
    property alias control: row
    signal eventRaised(string name, var payload)
    implicitWidth: 420
    implicitHeight: Math.max(180, row.implicitHeight + tokens.spacing * 2)
    LayoutMirroring.enabled: root.args.rtl === true
    LayoutMirroring.childrenInherit: true
    UI.Theme {
        id: tokens
        dark: root.dark
        density: root.args.density ?? "default"
        fontScale: root.args.fontScale ?? 1
        radius: root.args.radius ?? 8
    }
    function reset() { localSelected = root.args.selected === true; }
    Component.onCompleted: reset()
    onArgsChanged: reset()
    UI.ListItem {
        id: row
        objectName: "storyListItem"
        x: tokens.spacing; y: tokens.spacing
        width: root.width - tokens.spacing * 2
        theme: tokens
        size: root.args.size ?? "default"
        text: root.args.text ?? "Design notes"
        description: root.args.description ?? "Shared notes for the next iteration."
        selected: root.localSelected
        highlighted: root.args.highlighted === true
        enabled: root.args.disabled !== true
        leading: root.args.slots === true ? leadingContent : null
        trailing: root.args.slots === true ? trailingContent : null
        onClicked: {
            root.localSelected = !root.localSelected;
            root.eventRaised("activated", {selected: root.localSelected});
        }
    }
    Component {
        id: leadingContent
        Rectangle {
            implicitWidth: tokens.handleSize * 1.5
            implicitHeight: implicitWidth
            radius: width / 2
            color: tokens.surfaceHover
            Text {
                anchors.centerIn: parent
                text: "DN"
                font.family: tokens.fontFamily
                font.pixelSize: tokens.smallFontSize
                color: tokens.foreground
            }
        }
    }
    Component {
        id: trailingContent
        Text {
            text: "3 new"
            font.family: tokens.fontFamily
            font.pixelSize: tokens.smallFontSize
            color: row.descriptionColor
        }
    }
}
