pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root
    required property var catalog
    property alias explorerState: modelState
    property alias preview: storyLoader
    readonly property bool compact: width < 1050
    signal reloadRequested()
    color: colors.bg
    implicitWidth: 1320
    implicitHeight: 840

    Theme { id: colors; dark: modelState.dark }
    ExplorerState { id: modelState; entries: root.catalog }
    function focusSearch() {
        if (compact) {
            browserPopup.open();
            compactBrowser.focusSearch();
        } else sidebar.focusSearch();
    }
    Shortcut { sequence: "Ctrl+K"; onActivated: root.focusSearch() }
    Shortcut { sequence: "Ctrl+R"; onActivated: root.reloadRequested() }
    Shortcut { sequence: "Ctrl+0"; onActivated: modelState.reset() }

    Popup {
        id: browserPopup
        parent: root
        x: 16; y: 74
        width: Math.min(300, root.width - 32)
        height: Math.min(480, root.height - 100)
        padding: 1
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: colors.panel; border.color: colors.line; radius: 8 }
        contentItem: StoryBrowser {
            id: compactBrowser
            theme: colors
            modelState: root.explorerState
            searchName: "compactStorySearch"
            onSelected: browserPopup.close()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: colors.panel
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 12
                Rectangle {
                    implicitWidth: 32; implicitHeight: 32; radius: 9; color: colors.accent
                    Text { anchors.centerIn: parent; text: "Q"; color: colors.bg; font.pixelSize: 21; font.bold: true }
                }
                Text { text: "Quickbook"; color: colors.text; font.pixelSize: 20; font.weight: Font.DemiBold }
                Rectangle { visible: !root.compact; implicitWidth: 1; implicitHeight: 20; color: colors.line; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                Text { visible: !root.compact; text: "A little space for your components."; color: colors.muted; font.pixelSize: 12; Layout.fillWidth: true }
                UiButton { theme: colors; text: "Components"; visible: root.compact; onClicked: root.focusSearch() }
                Item { visible: root.compact; Layout.fillWidth: true }
                Rectangle { visible: !root.compact; implicitWidth: 6; implicitHeight: 6; radius: 3; color: colors.green }
                Text { visible: !root.compact; text: "LIVE QML"; color: colors.muted; font.pixelSize: 10; font.letterSpacing: 1; Layout.rightMargin: 12 }
                UiButton { theme: colors; text: modelState.dark ? "Light theme" : "Dark theme"; onClicked: modelState.dark = !modelState.dark }
                UiButton { theme: colors; text: "Reload"; onClicked: root.reloadRequested(); ToolTip.visible: hovered; ToolTip.text: "Reload QML · Ctrl+R" }
            }
        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: colors.line }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            StoryBrowser {
                id: sidebar
                visible: !root.compact
                Layout.preferredWidth: 224
                Layout.fillHeight: true
                theme: colors
                modelState: root.explorerState
            }
            Rectangle { visible: !root.compact; Layout.fillHeight: true; implicitWidth: 1; color: colors.line }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: modelState.story ? modelState.story.group + "  /" : "LIBRARY"; color: colors.muted; font.pixelSize: 11 }
                            Text { elide: Text.ElideRight; text: modelState.story ? modelState.story.title : "No stories yet"; color: colors.text; font.pixelSize: 18; font.weight: Font.DemiBold; Layout.fillWidth: true }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelState.story ? modelState.story.description : "Add a story to stories/Catalog.qml to get started."
                            color: colors.muted
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }
                }
                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: colors.line }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 8
                        Text { visible: !root.compact; text: "CANVAS"; color: colors.muted; font.pixelSize: 10; font.letterSpacing: 1; Layout.fillWidth: true }
                        UiSelect {
                            theme: colors
                            model: ["Fit to canvas", "Compact · 360", "Wide · 640"]
                            implicitWidth: 150
                            currentIndex: modelState.viewportWidth === 360 ? 1 : modelState.viewportWidth === 640 ? 2 : 0
                            onActivated: modelState.viewportWidth = [0, 360, 640][currentIndex]
                        }
                        UiSelect {
                            theme: colors
                            model: ["Auto height", "240 px", "360 px", "480 px"]
                            implicitWidth: 110
                            currentIndex: [0, 240, 360, 480].indexOf(modelState.viewportHeight)
                            onActivated: modelState.viewportHeight = [0, 240, 360, 480][currentIndex]
                        }
                        UiButton { theme: colors; text: "Grid"; selected: modelState.grid; onClicked: modelState.grid = !modelState.grid }
                    }
                }
                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: colors.line }
                Item {
                    id: stage
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    Canvas {
                        id: dots
                        anchors.fill: parent
                        visible: modelState.grid
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        Connections { target: colors; function onDarkChanged() { dots.requestPaint(); } }
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = colors.line;
                            for (let x = 12; x < width; x += 20)
                                for (let y = 12; y < height; y += 20) ctx.fillRect(x, y, 1.5, 1.5);
                        }
                    }
                    Rectangle {
                        id: frame
                        anchors.centerIn: parent
                        width: Math.max(1, Math.min(modelState.viewportWidth || stage.width - 64, stage.width - 32))
                        height: Math.max(1, Math.min(modelState.viewportHeight || stage.height - 64, stage.height - 32))
                        color: colors.panel
                        radius: 12
                        border.color: colors.line
                        clip: true
                        Loader {
                            id: storyLoader
                            objectName: "storyPreview"
                            anchors.centerIn: parent
                            width: item ? Math.min((item as Item).implicitWidth || frame.width - 32, frame.width - 32) : 0
                            height: item ? Math.min((item as Item).implicitHeight || frame.height - 32, frame.height - 32) : 0
                            function loadStory() {
                                source = "";
                                if (modelState.story) setSource(modelState.story.source, {args: modelState.args, dark: modelState.dark});
                            }
                            Component.onCompleted: loadStory()
                            Connections {
                                target: modelState
                                function onStoryChanged() { storyLoader.loadStory(); }
                                function onArgsChanged() { if (storyLoader.item) storyLoader.item.args = modelState.args; }
                                function onDarkChanged() { if (storyLoader.item) storyLoader.item.dark = modelState.dark; }
                            }
                        }
                        Connections {
                            target: storyLoader.item
                            function onEventRaised(name, payload) { modelState.logEvent(name, payload); }
                        }
                        Column {
                            anchors.centerIn: parent
                            width: parent.width - 40
                            spacing: 8
                            visible: storyLoader.status === Loader.Error
                            Text { text: "This story couldn’t load"; color: colors.text; font.pixelSize: 15; font.bold: true }
                            Text {
                                width: parent.width
                                text: "Check the QML error in your terminal, fix the story, and reload.\n" + (modelState.story ? modelState.story.source : "")
                                color: colors.muted; font.pixelSize: 12; wrapMode: Text.WrapAnywhere
                            }
                        }
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 9
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Math.round(frame.width) + " × " + Math.round(frame.height) + "  ·  " + (modelState.dark ? "DARK" : "LIGHT")
                        color: colors.muted; font.pixelSize: 9; font.letterSpacing: 1
                    }
                }
                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: colors.line }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.height < 780 ? 120 : 178
                    color: colors.panel
                    property int tab: 0
                    id: inspector
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            UiButton { theme: colors; text: "Events  ·  " + modelState.events.length; selected: inspector.tab === 0; onClicked: inspector.tab = 0 }
                            UiButton { theme: colors; text: "Arguments"; selected: inspector.tab === 1; onClicked: inspector.tab = 1 }
                            Item { Layout.fillWidth: true }
                            UiButton { theme: colors; text: "Clear"; visible: inspector.tab === 0; enabled: modelState.events.length > 0; onClicked: modelState.events = [] }
                        }
                        ListView {
                            id: eventList
                            visible: inspector.tab === 0
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 6
                            model: modelState.events
                            delegate: RowLayout {
                                id: eventRow
                                required property var modelData
                                width: eventList.width
                                spacing: 12
                                Text { text: eventRow.modelData.time; color: colors.muted; font.pixelSize: 10; font.family: "monospace" }
                                Text { text: eventRow.modelData.name; color: colors.accent; font.pixelSize: 11; font.family: "monospace" }
                                Text { text: eventRow.modelData.payload; color: colors.text; font.pixelSize: 11; font.family: "monospace"; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                            Text {
                                visible: !modelState.events.length
                                anchors.centerIn: parent
                                width: parent.width
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                text: "Interact with the component. Its events will appear here."
                                color: colors.muted; font.pixelSize: 11
                            }
                            ScrollBar.vertical: ScrollBar { }
                        }
                        ScrollView {
                            visible: inspector.tab === 1
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            TextArea {
                                text: JSON.stringify(modelState.args, null, 2)
                                readOnly: true
                                selectByMouse: true
                                color: colors.text
                                font.pixelSize: 11
                                font.family: "monospace"
                                background: null
                                selectionColor: colors.accent
                                selectedTextColor: colors.bg
                            }
                        }
                    }
                }
            }
            Rectangle { Layout.fillHeight: true; implicitWidth: 1; color: colors.line }
            Rectangle {
                Layout.preferredWidth: root.compact ? 240 : 276
                Layout.fillHeight: true
                color: colors.panel
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Story controls"; color: colors.text; font.pixelSize: 14; font.weight: Font.DemiBold; Layout.fillWidth: true }
                        Rectangle { implicitWidth: 6; implicitHeight: 6; radius: 3; color: modelState.modified ? colors.accent : colors.green }
                    }
                    Text { Layout.fillWidth: true; wrapMode: Text.WordWrap; text: "Start with a state. Then make it your own."; color: colors.muted; font.pixelSize: 10 }
                    Text { text: "PRESET"; color: colors.muted; font.pixelSize: 10; font.letterSpacing: 1 }
                    UiSelect {
                        theme: colors
                        Layout.fillWidth: true
                        model: modelState.story ? modelState.story.presets.map(p => p.name) : []
                        currentIndex: modelState.presetIndex
                        onActivated: modelState.preset(currentIndex)
                    }
                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: colors.line }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: availableWidth
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 24
                            Repeater {
                                model: modelState.story ? modelState.story.controls : []
                                ControlEditor {
                                    required property var modelData
                                    theme: colors
                                    spec: modelData
                                    value: modelState.args[modelData.key]
                                    Layout.fillWidth: true
                                    onEdited: newValue => modelState.setArg(modelData.key, newValue)
                                }
                            }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: colors.line }
                    UiButton {
                        theme: colors
                        text: "Reset to preset"
                        Layout.fillWidth: true
                        onClicked: modelState.reset()
                        ToolTip.visible: hovered
                        ToolTip.text: "Restore the current preset · Ctrl+0"
                    }
                    Text { text: "Mock data. Real components."; color: colors.muted; font.pixelSize: 10; Layout.alignment: Qt.AlignHCenter }
                }
            }
        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: colors.line }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                Text { text: "QUICKBOOK / 0.1"; color: colors.muted; font.pixelSize: 9; font.letterSpacing: 0.8 }
                Item { Layout.fillWidth: true }
                Text { text: "Ctrl+K  search     Ctrl+R  reload     Ctrl+0  reset"; color: colors.muted; font.pixelSize: 10 }
            }
        }
    }
}
