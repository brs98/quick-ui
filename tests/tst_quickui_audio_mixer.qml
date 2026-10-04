import QtQuick
import QtTest
import "../registry/quickui" as UI

Item {
    width: 800
    height: 800
    Component {
        id: mixerFactory
        UI.AudioMixer {
            width: 380
            height: 480
            theme: UI.Theme { motionDuration: 0 }
            hasOutput: true
            hasInput: true
            outputVolume: 0.5
            inputVolume: 0.6
            outputs: [{id: "out-a", label: "Speakers", glyph: "♪", current: true}, {id: "out-b", label: "Headphones", glyph: "♪", current: false}]
            inputs: [{id: "in-a", label: "Microphone", glyph: "●", current: true}]
            streams: [{id: "stream-a", label: "Music", volume: 0.7, muted: false, current: true}]
            statusText: "Playing quietly"
        }
    }
    SignalSpy { id: spy }
    TestCase {
        name: "QuickUIAudioMixer"
        when: windowShown
        property var mixer
        function init() {
            failOnWarning(/.*/);
            mouseMove(parent, 780, 780);
            mixer = createTemporaryObject(mixerFactory, parent);
            verify(mixer !== null);
            verify(waitForRendering(mixer));
            spy.target = null;
            spy.clear();
        }
        function cleanup() { spy.target = null; }
        function watch(name) { spy.target = null; spy.signalName = name; spy.target = mixer; spy.clear(); }
        function child(name) { const item = findChild(mixer, name); verify(item !== null, name); return item; }
        function panel() { mixer.panelNavigation = true; mixer.reset(); mixer.forceActiveFocus(); }
        function cursor(section, index) { mixer.setCursor(section, index); }
        function click(item) { mouseClick(item, item.width / 2, item.height / 2); }

        function test_firstArrowRevealsWithoutChangingVolume() {
            panel();
            watch("outputVolumeRequested");
            keyClick(Qt.Key_Right);
            compare(mixer.cursorActive, true);
            compare(mixer.focusSection, "output");
            compare(mixer.selectedIndex, -1);
            compare(spy.count, 0);
            keyClick(Qt.Key_Right);
            compare(spy.count, 1);
            fuzzyCompare(spy.signalArguments[0][0], 0.55, 0.00001);
            compare(mixer.outputVolume, 0.5, "Requests never mutate owner state");
            keyClick(Qt.Key_J);
            compare(mixer.selectedIndex, 0);
            keyClick(Qt.Key_L);
            compare(spy.count, 1, "Device rows do not adjust global volume");
        }

        function test_navigationAndActivation() {
            panel();
            keyClick(Qt.Key_Down);
            keyClick(Qt.Key_Up);
            compare(mixer.focusSection, "header");
            watch("allMuteRequested");
            keyClick(Qt.Key_Space);
            compare(spy.count, 1);
            keyClick(Qt.Key_Down);
            watch("outputMuteRequested");
            keyClick(Qt.Key_Return);
            compare(spy.count, 1);
            keyClick(Qt.Key_J);
            watch("outputSelected");
            keyClick(Qt.Key_Return);
            compare(spy.signalArguments[0][0], "out-a");
            keyClick(Qt.Key_J);
            keyClick(Qt.Key_J);
            compare(mixer.focusSection, "input");
            compare(mixer.selectedIndex, -1);
            watch("inputMuteRequested");
            keyClick(Qt.Key_M);
            compare(spy.count, 1);
            keyClick(Qt.Key_J);
            watch("inputSelected");
            keyClick(Qt.Key_Return);
            compare(spy.signalArguments[0][0], "in-a");
            keyClick(Qt.Key_J);
            compare(mixer.focusSection, "streams");
            watch("streamMuteRequested");
            keyClick(Qt.Key_M);
            compare(spy.signalArguments[0][0], "stream-a");
            keyClick(Qt.Key_K);
            compare(mixer.focusSection, "input");
            compare(mixer.selectedIndex, 0);
        }

        function test_volumeBounds_data() {
            return [
                {tag: "output-upper", section: "output", index: -1, volume: "outputVolume", value: 0.99, signal: "outputVolumeRequested", key: Qt.Key_Right, expected: 1},
                {tag: "input-lower", section: "input", index: -1, volume: "inputVolume", value: 0.01, signal: "inputVolumeRequested", key: Qt.Key_Left, expected: 0},
                {tag: "stream-upper", section: "streams", index: 0, volume: "", value: 1.49, signal: "streamVolumeRequested", key: Qt.Key_L, expected: 1.5},
                {tag: "stream-lower", section: "streams", index: 0, volume: "", value: 0.01, signal: "streamVolumeRequested", key: Qt.Key_H, expected: 0}
            ];
        }
        function test_volumeBounds(data) {
            panel();
            if (data.volume) mixer[data.volume] = data.value;
            else mixer.streams = [{id: "app", label: "App", volume: data.value, muted: false, current: false}];
            cursor(data.section, data.index);
            watch(data.signal);
            keyClick(data.key);
            compare(spy.count, 1);
            const args = spy.signalArguments[0];
            compare(args[args.length - 1], data.expected);
        }

        function test_panelTabAndEscape() {
            panel();
            watch("panelSwitchRequested");
            keyClick(Qt.Key_Tab);
            keyClick(Qt.Key_Tab, Qt.ShiftModifier);
            compare(spy.count, 2);
            compare(spy.signalArguments[0][0], 1);
            compare(spy.signalArguments[1][0], -1);
            watch("closeRequested");
            keyClick(Qt.Key_Escape);
            compare(spy.count, 1);
        }

        function test_standaloneNativeFocusAndKeyboard() {
            compare(mixer.panelNavigation, false);
            const output = child("audioOutput");
            output.slider.forceActiveFocus(Qt.TabFocusReason);
            watch("outputVolumeRequested");
            keyClick(Qt.Key_Right);
            compare(spy.count, 1, "Standalone slider does not require cursor reveal");
            fuzzyCompare(spy.signalArguments[0][0], 0.55, 0.00001);
            watch("panelSwitchRequested");
            keyClick(Qt.Key_Tab);
            compare(spy.count, 0);
            compare(child("audioOutputDevice0").activeFocus, true);
            watch("outputSelected");
            keyClick(Qt.Key_Space);
            compare(spy.signalArguments[0][0], "out-a");
            watch("closeRequested");
            keyClick(Qt.Key_Escape);
            compare(spy.count, 1);
            mixer.panelNavigation = true;
            mixer.reset();
            watch("outputVolumeRequested");
            keyClick(Qt.Key_Right);
            compare(spy.count, 0, "Changing modes clears child focus and restores first-arrow reveal");
        }

        function test_scrollingCursorAndHotLists() {
            const streams = [];
            for (let i = 0; i < 20; ++i) streams.push({id: "s" + i, label: "Long application title " + i, volume: 0.5, muted: false, current: i === 19});
            mixer.streams = streams;
            panel();
            cursor("streams", 19);
            const scroll = child("audioScroll");
            tryVerify(() => scroll.contentY > 0);
            const row = child("audioStream19");
            tryVerify(() => row.mapToItem(scroll, 0, 0).y >= -0.5 && row.mapToItem(scroll, 0, row.height).y <= scroll.height + 0.5);
            mixer.streams = streams.slice(0, 1);
            tryCompare(mixer, "selectedIndex", 0);
            compare(mixer.focusSection, "streams");
            mixer.streams = [];
            tryCompare(mixer, "focusSection", "output");
            compare(mixer.selectedIndex, -1);
            cursor("input", 0);
            mixer.inputs = [];
            mixer.hasInput = false;
            tryCompare(mixer, "focusSection", "output");
            mixer.reset();
            compare(scroll.contentY, 0);
            compare(mixer.cursorActive, false);
        }

        function test_pointerAndControlledMute() {
            const device = child("audioOutputDevice1");
            mixer.ensureVisible(device);
            verify(waitForRendering(mixer));
            mouseMove(device, 10, device.height / 2);
            tryCompare(mixer, "selectedIndex", 1);
            compare(mixer.focusSection, "output");
            watch("outputSelected");
            click(device);
            compare(spy.signalArguments[0][0], "out-b");
            const master = child("audioAllMute");
            mixer.ensureVisible(master);
            verify(waitForRendering(mixer));
            watch("allMuteRequested");
            click(master);
            compare(spy.count, 1);
            compare(master.checked, true, "Rejected mute requests preserve owner state");
            mixer.outputMuted = true;
            mixer.inputMuted = true;
            compare(master.checked, false, "Later backend state remains bound");
            mixer.inputMuted = false;
            compare(master.checked, true);
        }

        function test_snapshotReplacementKeepsDragAndFocus() {
            const device = child("audioOutputDevice1");
            device.forceActiveFocus(Qt.TabFocusReason);
            mixer.outputs = mixer.outputs.map(row => Object.assign({}, row, {current: row.id === "out-b"}));
            compare(child("audioOutputDevice1"), device);
            compare(device.activeFocus, true);
            compare(device.current, true);
            mixer.outputs = [mixer.outputs[1], mixer.outputs[0]];
            compare(child("audioOutputDevice0"), device, "Reorder retains the keyed delegate");
            compare(device.activeFocus, true);

            const stream = child("audioStream0");
            const slider = stream.slider;
            mixer.ensureVisible(stream);
            verify(waitForRendering(mixer));
            function accept(id, value) {
                mixer.streams = mixer.streams.map(row => Object.assign({}, row,
                    row.id === id ? {volume: value} : {}));
            }
            mixer.streamVolumeRequested.connect(accept);
            watch("streamVolumeRequested");
            const center = slider.handle.x + slider.handle.width / 2;
            mousePress(slider, center, slider.height / 2);
            verify(slider.pressed);
            mouseMove(slider, slider.width * 0.65, slider.height / 2);
            verify(spy.count > 0);
            compare(child("audioStream0"), stream);
            compare(slider.pressed, true, "Owner snapshot update must retain the active mouse grab");
            const first = mixer.streams[0].volume;
            mouseMove(slider, slider.width * 0.85, slider.height / 2);
            verify(mixer.streams[0].volume > first, "The same held drag continues updating volume");
            mouseRelease(slider, slider.width * 0.85, slider.height / 2);
            verify(!slider.pressed);
            compare(slider.value, mixer.streams[0].volume);
            slider.forceActiveFocus(Qt.TabFocusReason);
            mixer.streams = mixer.streams.map(row => Object.assign({}, row, {volume: 0.25}));
            compare(slider.activeFocus, true);
            compare(slider.value, 0.25);
            mixer.streamVolumeRequested.disconnect(accept);
        }

        function test_controlCompositionAndMuteRequests() {
            const output = child("audioOutput");
            const input = child("audioInput");
            const stream = child("audioStream0");
            compare(output.theme, mixer.theme);
            compare(input.theme, mixer.theme);
            compare(stream.theme, mixer.theme);
            compare(child("audioOutputDevice0").current, true);
            compare(stream.active, true);
            mixer.inputPeak = 0.83;
            compare(input.peak, 0.83);
            compare(input.showMeter, true);
            mixer.outputVolume = 0.73;
            compare(mixer.liveOutputVolume, 0.73);
            watch("outputMuteRequested");
            click(output.muteButton);
            compare(spy.count, 1);
            compare(mixer.outputMuted, false);
            mixer.ensureVisible(input);
            verify(waitForRendering(mixer));
            watch("inputMuteRequested");
            click(input.muteButton);
            compare(spy.count, 1);
            stream.muteButton.forceActiveFocus(Qt.TabFocusReason);
            const scroll = child("audioScroll");
            tryVerify(() => stream.mapToItem(scroll, 0, stream.height).y <= scroll.height + 0.5);
            watch("streamMuteRequested");
            keyClick(Qt.Key_Space);
            compare(spy.count, 1);
            compare(spy.signalArguments[0][0], "stream-a");
        }

        function test_unavailableAndLongLabels() {
            mixer.hasOutput = false;
            mixer.hasInput = false;
            mixer.outputs = [];
            mixer.inputs = [];
            mixer.streams = [];
            mixer.statusText = "A very long status that should never expand the mixer beyond its requested width";
            compare(child("audioAllMute").enabled, false);
            compare(child("audioOutput").slider.enabled, false);
            compare(child("audioInput").visible, false);
            panel();
            cursor("output", -1);
            watch("outputVolumeRequested");
            keyClick(Qt.Key_L);
            compare(spy.count, 0);
            watch("outputMuteRequested");
            keyClick(Qt.Key_M);
            compare(spy.count, 0);
            compare(mixer.implicitWidth, 380);
            verify(mixer.implicitHeight > 0);
        }
    }
}
