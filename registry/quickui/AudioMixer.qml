pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls

// A presentation-only audio panel. The consumer owns device identity and state.
FocusScope {
    id: root
    property Theme theme: Theme {}
    property var outputs: []
    property var inputs: []
    property var streams: []
    property bool hasOutput: false
    property bool hasInput: false
    property real outputVolume: 0
    property real inputVolume: 0
    property bool outputMuted: false
    property bool inputMuted: false
    property real inputPeak: 0
    property string outputGlyph: "♪"
    property string statusText: ""
    property bool panelNavigation: false
    readonly property real liveOutputVolume: outputControl.liveValue

    signal outputVolumeRequested(real value)
    signal inputVolumeRequested(real value)
    signal outputMuteRequested()
    signal inputMuteRequested()
    signal allMuteRequested()
    signal outputSelected(string id)
    signal inputSelected(string id)
    signal streamVolumeRequested(string id, real value)
    signal streamMuteRequested(string id)
    signal closeRequested()
    signal panelSwitchRequested(int direction)

    // Exposed for consumers that want to announce or inspect the panel cursor.
    property string focusSection: "output"
    property int selectedIndex: -1
    property bool cursorActive: false
    readonly property bool anyAudible: (hasOutput && !outputMuted) || (hasInput && !inputMuted)
    readonly property bool inputVisible: hasInput || inputs.length > 0
    readonly property var cursorRows: {
        const rows = [{section: "header", index: -1}, {section: "output", index: -1}];
        for (let i = 0; i < outputs.length; ++i) rows.push({section: "output", index: i});
        if (inputVisible) {
            if (hasInput) rows.push({section: "input", index: -1});
            for (let i = 0; i < inputs.length; ++i) rows.push({section: "input", index: i});
        }
        for (let i = 0; i < streams.length; ++i) rows.push({section: "streams", index: i});
        return rows;
    }
    implicitWidth: 380
    implicitHeight: contentColumn.implicitHeight

    // Array snapshots are an external API; keyed models preserve native controls
    // during asynchronous value updates, including the item holding a drag grab.
    ListModel { id: outputModel }
    ListModel { id: inputModel }
    ListModel { id: streamModel }
    function reconcile(model, rows, section) {
        if (!model) return;
        const retainedId = focusSection === section && selectedIndex >= 0 && selectedIndex < model.count
            ? model.get(selectedIndex).key : "";
        let destination = 0;
        for (const row of rows) {
            const key = String(row.id);
            const data = {key: key, label: String(row.label || ""), glyph: String(row.glyph || ""),
                current: row.current === true, volume: bounded(Number(row.volume), 1.5), muted: row.muted === true};
            let existing = -1;
            for (let index = destination; index < model.count; ++index) {
                if (model.get(index).key === key) { existing = index; break; }
            }
            if (existing < 0) model.insert(destination, data);
            else {
                if (existing !== destination) model.move(existing, destination, 1);
                model.set(destination, data);
            }
            destination++;
        }
        if (model.count > destination) model.remove(destination, model.count - destination);
        if (retainedId !== "") {
            for (let index = 0; index < model.count; ++index) {
                if (model.get(index).key === retainedId) { selectedIndex = index; break; }
            }
        }
        repairCursor();
    }
    onOutputsChanged: reconcile(outputModel, outputs, "output")
    onInputsChanged: reconcile(inputModel, inputs, "input")
    onStreamsChanged: reconcile(streamModel, streams, "streams")
    Component.onCompleted: {
        reconcile(outputModel, outputs, "output");
        reconcile(inputModel, inputs, "input");
        reconcile(streamModel, streams, "streams");
    }

    function bounded(value, maximum) { return Number.isFinite(value) ? Math.max(0, Math.min(maximum, value)) : 0; }
    function hasCursor(section, index) { return cursorActive && focusSection === section && selectedIndex === index; }
    function setCursor(section, index) {
        focusSection = section;
        selectedIndex = index;
        cursorActive = true;
    }
    function reset() {
        cursorActive = false;
        focusSection = "output";
        selectedIndex = -1;
        scroll.contentY = 0;
        if (panelNavigation) panelKeys.forceActiveFocus();
    }
    function repairCursor() {
        if (!cursorRows) return; // Initial property bindings can precede the cursor model.
        const sameSection = cursorRows.filter(row => row.section === focusSection);
        if (!sameSection.length) { focusSection = "output"; selectedIndex = -1; }
        else selectedIndex = Math.max(sameSection[0].index, Math.min(sameSection[sameSection.length - 1].index, selectedIndex));
        Qt.callLater(revealCursor);
    }
    function cursorItem() {
        if (focusSection === "header") return hero;
        if (focusSection === "output") return selectedIndex === -1 ? outputControl : outputRows.itemAt(selectedIndex);
        if (focusSection === "input") return selectedIndex === -1 ? inputControl : inputRows.itemAt(selectedIndex);
        return streamRows.itemAt(selectedIndex);
    }
    function ensureVisible(item) {
        if (!item || !item.visible) return;
        const top = item.mapToItem(contentColumn, 0, 0).y;
        const bottom = top + item.height;
        const maximum = Math.max(0, scroll.contentHeight - scroll.height);
        if (item.height > scroll.height || top < scroll.contentY)
            scroll.contentY = Math.max(0, Math.min(maximum, top));
        else if (bottom > scroll.contentY + scroll.height)
            scroll.contentY = Math.max(0, Math.min(maximum, bottom - scroll.height));
    }
    function revealCursor() { if (cursorActive) ensureVisible(cursorItem()); }
    function moveCursor(direction) {
        const current = cursorRows.findIndex(row => row.section === focusSection && row.index === selectedIndex);
        const next = cursorRows[Math.max(0, Math.min(cursorRows.length - 1, current + direction))];
        setCursor(next.section, next.index);
    }
    function adjustVolume(delta) {
        if (focusSection === "output" && selectedIndex === -1 && hasOutput)
            outputVolumeRequested(bounded(outputVolume + delta, 1));
        else if (focusSection === "input" && selectedIndex === -1 && hasInput)
            inputVolumeRequested(bounded(inputVolume + delta, 1));
        else if (focusSection === "streams" && streams[selectedIndex]) {
            const stream = streams[selectedIndex];
            streamVolumeRequested(String(stream.id), bounded(stream.volume + delta, 1.5));
        }
    }
    function muteCursor() {
        if (!cursorActive) return;
        if (focusSection === "streams" && streams[selectedIndex]) streamMuteRequested(String(streams[selectedIndex].id));
        else if (focusSection === "input") { if (hasInput) inputMuteRequested(); }
        else if (hasOutput) outputMuteRequested();
    }
    function activateCursor() {
        if (!cursorActive) return;
        if (focusSection === "header") { if (hasOutput || hasInput) allMuteRequested(); }
        else if (focusSection === "output" && selectedIndex >= 0 && outputs[selectedIndex]) outputSelected(String(outputs[selectedIndex].id));
        else if (focusSection === "input" && selectedIndex >= 0 && inputs[selectedIndex]) inputSelected(String(inputs[selectedIndex].id));
        else muteCursor();
    }
    function handleKey(event) {
        if (event.key === Qt.Key_Escape) { closeRequested(); event.accepted = true; return; }
        if (!panelNavigation) return;
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            panelSwitchRequested(event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier) ? -1 : 1);
        } else if ([Qt.Key_Up, Qt.Key_K, Qt.Key_Down, Qt.Key_J, Qt.Key_Left, Qt.Key_H, Qt.Key_Right, Qt.Key_L].includes(event.key)) {
            if (!cursorActive) cursorActive = true;
            else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) moveCursor(-1);
            else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) moveCursor(1);
            else adjustVolume(event.key === Qt.Key_Left || event.key === Qt.Key_H ? -0.05 : 0.05);
        } else if ([Qt.Key_Enter, Qt.Key_Return, Qt.Key_Space].includes(event.key)) activateCursor();
        else if (event.key === Qt.Key_M) muteCursor();
        else return;
        event.accepted = true;
    }
    Keys.priority: Keys.BeforeItem
    Keys.onPressed: event => handleKey(event)
    onCursorRowsChanged: repairCursor()
    onFocusSectionChanged: Qt.callLater(revealCursor)
    onSelectedIndexChanged: Qt.callLater(revealCursor)
    onCursorActiveChanged: Qt.callLater(revealCursor)
    onPanelNavigationChanged: if (panelNavigation) panelKeys.forceActiveFocus()
    Item { id: panelKeys; focus: root.panelNavigation }

    Flickable {
        id: scroll
        objectName: "audioScroll"
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        onHeightChanged: Qt.callLater(root.revealCursor)
        onContentHeightChanged: Qt.callLater(root.revealCursor)
        Controls.ScrollBar.vertical: Controls.ScrollBar {
            id: bar
            policy: Controls.ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: 4
                implicitHeight: 24
                radius: 2
                color: bar.pressed ? root.theme.accent : root.theme.mutedForeground
                opacity: bar.size < 1 ? 0.7 : 0
            }
            background: Rectangle { color: "transparent" }
        }
        Column {
            id: contentColumn
            width: scroll.width - (scroll.contentHeight > scroll.height ? root.theme.spacing : 0)
            spacing: root.theme.spacing * 1.5
            Item {
                id: hero
                objectName: "audioHeader"
                width: parent.width
                implicitHeight: Math.max(root.theme.controlHeight, heroLabels.implicitHeight)
                Rectangle {
                    anchors.fill: parent
                    radius: root.theme.radius
                    color: "transparent"
                    border.width: root.hasCursor("header", -1) ? root.theme.focusWidth : 0
                    border.color: root.theme.focus
                }
                Text {
                    id: heroGlyph
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.outputGlyph
                    textFormat: Text.PlainText
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize * 2
                    color: root.theme.foreground
                    opacity: root.outputMuted ? root.theme.disabledOpacity : 1
                }
                Column {
                    id: heroLabels
                    anchors.left: heroGlyph.right
                    anchors.leftMargin: root.theme.spacing
                    anchors.right: masterSwitch.left
                    anchors.rightMargin: root.theme.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        width: parent.width
                        text: "Audio"
                        textFormat: Text.PlainText
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize + 5
                        font.bold: true
                        color: root.theme.foreground
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: root.statusText
                        textFormat: Text.PlainText
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.smallFontSize
                        color: root.theme.mutedForeground
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }
                }
                Switch {
                    id: masterSwitch
                    objectName: "audioAllMute"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    theme: root.theme
                    checked: root.anyAudible
                    enabled: root.hasOutput || root.hasInput
                    focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                    Accessible.name: root.anyAudible ? "Mute all audio" : "Unmute all audio"
                    onToggled: {
                        root.allMuteRequested();
                        checked = Qt.binding(function() { return root.anyAudible; });
                    }
                    onHoveredChanged: if (hovered) root.setCursor("header", -1)
                    onActiveFocusChanged: if (activeFocus) root.ensureVisible(hero)
                    ToolTip { theme: root.theme; visible: masterSwitch.hovered; text: masterSwitch.Accessible.name }
                }
            }
            Separator { width: parent.width; theme: root.theme }
            VolumeControl {
                id: outputControl
                objectName: "audioOutput"
                width: parent.width
                theme: root.theme
                title: "Output"
                glyph: root.outputGlyph
                value: root.outputVolume
                muted: root.outputMuted
                available: root.hasOutput
                cursorHighlighted: root.hasCursor("output", -1)
                slider.focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                muteButton.focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                onVolumeRequested: value => root.outputVolumeRequested(root.bounded(value, 1))
                onMuteRequested: root.outputMuteRequested()
                onHovered: root.setCursor("output", -1)
            }
            Repeater {
                id: outputRows
                model: outputModel
                delegate: DeviceItem {
                    required property var model
                    required property int index
                    objectName: "audioOutputDevice" + index
                    width: contentColumn.width
                    theme: root.theme
                    text: model.label
                    glyph: model.glyph || "♪"
                    current: model.current === true
                    cursorHighlighted: root.hasCursor("output", index)
                    focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                    onClicked: root.outputSelected(model.key)
                    onHoveredChanged: if (hovered) root.setCursor("output", index)
                    onActiveFocusChanged: if (activeFocus) root.ensureVisible(this)
                }
            }
            Text {
                width: parent.width
                visible: root.outputs.length === 0
                text: "No output devices"
                color: root.theme.mutedForeground
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
                wrapMode: Text.WordWrap
            }
            Separator { width: parent.width; theme: root.theme; visible: root.inputVisible }
            VolumeControl {
                id: inputControl
                objectName: "audioInput"
                width: parent.width
                visible: root.hasInput
                theme: root.theme
                title: "Input"
                glyph: "●"
                value: root.inputVolume
                muted: root.inputMuted
                available: root.hasInput
                showMeter: true
                peak: root.inputPeak
                cursorHighlighted: root.hasCursor("input", -1)
                slider.focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                muteButton.focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                onVolumeRequested: value => root.inputVolumeRequested(root.bounded(value, 1))
                onMuteRequested: root.inputMuteRequested()
                onHovered: root.setCursor("input", -1)
            }
            Repeater {
                id: inputRows
                model: inputModel
                delegate: DeviceItem {
                    required property var model
                    required property int index
                    objectName: "audioInputDevice" + index
                    width: contentColumn.width
                    theme: root.theme
                    text: model.label
                    glyph: model.glyph || "●"
                    current: model.current === true
                    cursorHighlighted: root.hasCursor("input", index)
                    focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                    onClicked: root.inputSelected(model.key)
                    onHoveredChanged: if (hovered) root.setCursor("input", index)
                    onActiveFocusChanged: if (activeFocus) root.ensureVisible(this)
                }
            }
            Separator { width: parent.width; theme: root.theme; visible: root.streams.length > 0 }
            Text {
                width: parent.width
                visible: root.streams.length > 0
                text: "Applications"
                color: root.theme.mutedForeground
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.smallFontSize
                font.bold: true
            }
            Repeater {
                id: streamRows
                model: streamModel
                delegate: VolumeControl {
                    id: streamControl
                    required property var model
                    required property int index
                    objectName: "audioStream" + index
                    width: contentColumn.width
                    theme: root.theme
                    title: model.label
                    glyph: "♪"
                    value: model.volume
                    maximum: 1.5
                    muted: model.muted === true
                    active: model.current === true
                    cursorHighlighted: root.hasCursor("streams", index)
                    slider.focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                    muteButton.focusPolicy: root.panelNavigation ? Qt.NoFocus : Qt.StrongFocus
                    onVolumeRequested: value => root.streamVolumeRequested(model.key, root.bounded(value, 1.5))
                    onMuteRequested: root.streamMuteRequested(model.key)
                    onHovered: root.setCursor("streams", index)
                    Connections { target: streamControl.slider; function onActiveFocusChanged() { if (streamControl.slider.activeFocus) root.ensureVisible(streamControl); } }
                    Connections { target: streamControl.muteButton; function onActiveFocusChanged() { if (streamControl.muteButton.activeFocus) root.ensureVisible(streamControl); } }
                }
            }
        }
    }
    Connections { target: outputControl.slider; function onActiveFocusChanged() { if (outputControl.slider.activeFocus) root.ensureVisible(outputControl); } }
    Connections { target: outputControl.muteButton; function onActiveFocusChanged() { if (outputControl.muteButton.activeFocus) root.ensureVisible(outputControl); } }
    Connections { target: inputControl.slider; function onActiveFocusChanged() { if (inputControl.slider.activeFocus) root.ensureVisible(inputControl); } }
    Connections { target: inputControl.muteButton; function onActiveFocusChanged() { if (inputControl.muteButton.activeFocus) root.ensureVisible(inputControl); } }
}
