import QtQuick
import QtQuick.Controls.Basic as Controls
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool notifications: true
    property string arrangement: "Comfortable"
    property alias control: menu
    property alias trigger: trigger
    signal eventRaised(string name, var payload)
    implicitWidth: 360
    implicitHeight: 350
    LayoutMirroring.enabled: root.args.rtl === true
    LayoutMirroring.childrenInherit: true

    UI.Theme {
        id: tokens
        dark: root.dark
        density: root.args.density ?? "default"
        fontScale: root.args.fontScale ?? 1
    }
    function reset() {
        menu.close();
        arrangementMenu.close();
        notifications = root.args.checked !== false;
        arrangement = root.args.choice ?? "Comfortable";
    }
    Component.onCompleted: reset()
    onArgsChanged: reset()

    // Popup visuals are reparented into Qt's overlay, outside this Item's mirror scope.
    Binding { target: menu.contentItem.parent; property: "LayoutMirroring.enabled"; value: root.args.rtl === true }
    Binding { target: menu.contentItem.parent; property: "LayoutMirroring.childrenInherit"; value: true }
    Binding { target: arrangementMenu.contentItem.parent; property: "LayoutMirroring.enabled"; value: root.args.rtl === true }
    Binding { target: arrangementMenu.contentItem.parent; property: "LayoutMirroring.childrenInherit"; value: true }

    UI.Button {
        id: trigger
        objectName: "menuTrigger"
        x: tokens.spacing
        y: tokens.spacing
        theme: tokens
        width: Math.min(implicitWidth, root.width - tokens.spacing * 2)
        variant: "outline"
        text: root.args.label ?? "Workspace actions"
        onClicked: menu.open()
        UI.Menu {
            id: menu
            objectName: "storyMenu"
            theme: tokens
            y: trigger.height + tokens.spacing / 2
            width: Math.min(root.width - tokens.spacing * 2, 280 * tokens.fontScale)
            UI.MenuItem {
                objectName: "menuOpenItem"
                theme: tokens
                text: "Open workspace"
                icon.source: root.args.icons !== false ? Qt.resolvedUrl("assets/add.svg") : ""
                shortcutText: "Ctrl+O"
                onTriggered: root.eventRaised("openRequested", {})
            }
            UI.MenuItem {
                objectName: "menuDisabledItem"
                theme: tokens
                text: "Restore previous session"
                enabled: false
                onTriggered: root.eventRaised("restoreRequested", {})
            }
            UI.MenuSeparator { theme: tokens }
            UI.MenuItem {
                objectName: "menuNotificationsItem"
                theme: tokens
                text: "Notifications"
                checkable: true
                checked: root.notifications
                onTriggered: {
                    root.notifications = checked;
                    root.eventRaised("notificationsChanged", {checked: checked});
                }
            }
            UI.Menu {
                id: arrangementMenu
                objectName: "menuArrangement"
                    theme: tokens
                title: "Arrangement"
                Controls.ButtonGroup { id: arrangementGroup }
                UI.MenuItem {
                    objectName: "menuCompactItem"
                    theme: tokens
                    text: "Compact"
                    checkable: true
                    autoExclusive: true
                    indicatorType: "radio"
                    Controls.ButtonGroup.group: arrangementGroup
                    checked: root.arrangement === "Compact"
                    onTriggered: {
                        root.arrangement = "Compact";
                        root.eventRaised("arrangementChanged", {choice: root.arrangement});
                    }
                }
                UI.MenuItem {
                    objectName: "menuComfortableItem"
                    theme: tokens
                    text: "Comfortable"
                    checkable: true
                    autoExclusive: true
                    indicatorType: "radio"
                    Controls.ButtonGroup.group: arrangementGroup
                    checked: root.arrangement === "Comfortable"
                    onTriggered: {
                        root.arrangement = "Comfortable";
                        root.eventRaised("arrangementChanged", {choice: root.arrangement});
                    }
                }
            }
            UI.MenuSeparator { theme: tokens }
            UI.MenuItem {
                objectName: "menuDeleteItem"
                theme: tokens
                text: "Delete workspace"
                variant: "destructive"
                onTriggered: root.eventRaised("deleteRequested", {})
            }
        }
    }
    Text {
        anchors.top: trigger.bottom
        anchors.topMargin: tokens.spacing * 2
        x: tokens.spacing
        width: root.width - tokens.spacing * 2
        text: "Notifications " + (root.notifications ? "on" : "off") + " · " + root.arrangement
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: tokens.mutedForeground
        font.family: tokens.fontFamily
        font.pixelSize: tokens.smallFontSize
    }
}
