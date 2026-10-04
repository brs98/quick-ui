pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../registry/quickui" as UI

Rectangle {
    id: root
    required property var theme
    required property var modelState
    property string searchName: "storySearch"
    signal selected()
    color: theme.panel
    function focusSearch() { search.forceActiveFocus(); }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 18
        UI.TextField {
            id: search
            Accessible.name: "Find a component"
            objectName: root.searchName
            Layout.fillWidth: true
            theme: root.theme
            placeholderText: "Find a component…   Ctrl+K"
            text: root.modelState.query
            onTextEdited: root.modelState.query = text
        }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "COMPONENTS"; color: root.theme.muted; font.pixelSize: 10; font.letterSpacing: 1.5; Layout.fillWidth: true }
            Text { text: root.modelState.entries.length; color: root.theme.muted; font.pixelSize: 11 }
        }
        ListView {
            id: storyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            model: root.modelState.filtered
            delegate: ItemDelegate {
                id: entryDelegate
                required property var modelData
                width: storyList.width
                height: 65
                Accessible.name: modelData.entry.title
                objectName: root.searchName === "compactStorySearch" ? "compactStoryEntry" : "storyEntry"
                onClicked: { root.modelState.select(modelData.index); root.selected(); }
                background: Rectangle {
                    radius: 8
                    color: root.modelState.selectedIndex === entryDelegate.modelData.index ? root.theme.selected : entryDelegate.hovered ? root.theme.raised : "transparent"
                    border.color: entryDelegate.activeFocus ? root.theme.accent : "transparent"
                }
                contentItem: Column {
                    spacing: 5
                    Text { text: entryDelegate.modelData.entry.group; color: root.theme.muted; font.pixelSize: 10 }
                    Text {
                        text: entryDelegate.modelData.entry.title
                        color: root.modelState.selectedIndex === entryDelegate.modelData.index ? root.theme.accent : root.theme.text
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                }
            }
            Text {
                anchors.top: parent.top
                width: parent.width
                visible: root.modelState.filtered.length === 0
                text: "No components found.\nTry a different search."
                wrapMode: Text.WordWrap
                lineHeight: 1.5
                color: root.theme.muted
                font.pixelSize: 12
            }
        }
        UI.Separator { theme: root.theme; Layout.fillWidth: true }
        Text { text: "YOUR COMPONENT WORKBENCH"; color: root.theme.muted; font.pixelSize: 9; font.letterSpacing: 0.8 }
        Text { text: "Edit. Explore. Make it yours.\nChanges reload as you save."; color: root.theme.muted; font.pixelSize: 11; lineHeight: 1.5 }
    }
}
