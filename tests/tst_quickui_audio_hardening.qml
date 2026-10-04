import QtQuick
import QtTest
import "../registry/quickui" as UI
import "../stories/audio" as Stories

Item {
    width: 900; height: 900
    Component { id: meterFactory; UI.LevelMeter { width: 160; height: 6; value: 0.01; theme: UI.Theme { border: "black"; accent: "red" } } }
    Component { id: volumeFactory; UI.VolumeControl { width: 360; title: "Output"; value: 0.64; theme: UI.Theme { motionDuration: 0 } } }
    Component { id: deviceFactory; UI.DeviceItem { width: 320; text: "Speakers"; glyph: "♪"; theme: UI.Theme { motionDuration: 0 } } }
    Component {
        id: mixerFactory
        UI.AudioMixer {
            width: 380; height: 400
            theme: UI.Theme { motionDuration: 0 }
            hasOutput: true; outputVolume: 0.64
            outputs: [{id: "a", label: "Speakers", current: true}]
            inputs: [{id: "mic", label: "Microphone", description: "USB input", current: false}]
            streams: [{id: "music", label: "Music", volume: 0.8, muted: false, current: true}]
        }
    }
    Component { id: selectionFactory; Stories.DeviceItemStory { args: ({selectionList: true, current: true, description: "USB audio", rtl: true}) } }
    SignalSpy { id: clicks; signalName: "clicked" }
    TestCase {
        name: "QuickUIAudioHardening"
        when: windowShown
        function init() { failOnWarning(/.*/); mouseMove(parent, 890, 890); }
        function make(factory) { const item = createTemporaryObject(factory, parent); verify(item); verify(waitForRendering(item)); return item; }
        function child(root, name) { const item = findChild(root, name); verify(item !== null, name); return item; }
        function textItem(root, text) { return root.children.find(item => item.text === text); }
        function test_meterAccessibleValueAndRange() {
            const meter = make(meterFactory);
            const semantic = child(meter, "levelMeterAccessible");
            compare(semantic.minimumValue, 0); compare(semantic.maximumValue, 1);
            meter.value = 2; compare(semantic.value, 1);
            meter.value = NaN; compare(semantic.value, 0);
            meter.Accessible.name = "Microphone peak";
            compare(semantic.Accessible.name, "Microphone peak");
            meter.muted = true; compare(semantic.Accessible.description, "Muted");
        }
        function test_meterTinyFillStaysInsideRoundedTrack() {
            const meter = make(meterFactory);
            const image = grabImage(meter);
            // QtTest composites onto white. The corner should remain almost white;
            // a separately rounded 1.6px red fill incorrectly paints it opaque.
            verify(image.green(0, 0) > 200, "Tiny fill must retain the rounded track silhouette");
            meter.value = 1;
            wait(20);
            const full = grabImage(meter);
            verify(full.green(0, 0) > 200);
            verify(full.red(80, 3) > 200);
        }
        function test_volumeMirroredHeaderAndControls() {
            const volume = make(volumeFactory);
            volume.LayoutMirroring.enabled = true;
            volume.LayoutMirroring.childrenInherit = true;
            const title = child(volume, "volumeTitle");
            const percent = child(volume, "volumeValue");
            verify(percent.x + percent.width <= title.x, "RTL value must not overlap title");
            verify(volume.slider.x + volume.slider.width <= volume.muteButton.x, "Mute action belongs at RTL leading edge");
        }
        function test_volumeLargeFontAndContext() {
            const volume = make(volumeFactory);
            volume.theme.fontSize = 40;
            volume.showMeter = true;
            const meter = child(volume, "volumeMeter");
            verify(volume.muteButton.y + volume.muteButton.height <= meter.y);
            verify(meter.y + meter.height + volume.theme.padding <= volume.height + 0.5);
            verify(volume.slider.Accessible.description.indexOf("64%") >= 0);
            compare(meter.Accessible.name, "Output audio level");
            volume.muted = true;
            verify(volume.slider.Accessible.description.indexOf("Muted") >= 0);
        }
        function test_deviceDescriptionAndMirror() {
            const device = make(deviceFactory);
            const shortHeight = device.height;
            device.description = "External USB audio interface";
            tryVerify(() => device.height > shortHeight);
            verify(device.Accessible.description.indexOf("External USB") >= 0);
            device.current = true;
            compare(device.Accessible.role, Accessible.ListItem);
            compare(device.Accessible.selectable, true);
            compare(device.Accessible.selected, true);
            clicks.target = device; clicks.clear();
            device.Accessible.pressAction();
            compare(clicks.count, 1);
            compare(device.current, true, "AT activation must preserve controlled selection");
            device.enabled = false; device.Accessible.pressAction(); compare(clicks.count, 1); device.enabled = true;
            verify(device.Accessible.description.indexOf("Current device") >= 0);
            device.LayoutMirroring.enabled = true; device.LayoutMirroring.childrenInherit = true;
            const glyph = child(device, "deviceGlyph");
            const mark = child(device, "deviceCurrentMark");
            verify(glyph.x > mark.x, "RTL keeps glyph at leading edge");
        }
        function test_selectionRecipeKeepsExactlyOneCurrent() {
            const story = make(selectionFactory);
            const first = story.control;
            const second = child(story, "storySecondDevice");
            first.forceActiveFocus(); keyClick(Qt.Key_Space);
            compare(first.current, true); compare(second.current, false);
            second.forceActiveFocus(); keyClick(Qt.Key_Space);
            compare(first.current, false); compare(second.current, true);
            keyClick(Qt.Key_Space);
            compare(second.current, true);
        }
        function test_mixerInputHeadingWithoutDefaultDevice() {
            const mixer = make(mixerFactory);
            compare(mixer.hasInput, false);
            const heading = child(mixer, "audioInputHeading");
            verify(heading.visible); compare(heading.text, "Input");
            compare(child(mixer, "audioInputDevice0").description, "USB input");
        }
        function test_mixerFocusedControlStaysVisibleOnResize() {
            const mixer = make(mixerFactory);
            const row = child(mixer, "audioStream0");
            const scroll = child(mixer, "audioScroll");
            row.slider.forceActiveFocus(Qt.TabFocusReason);
            mixer.cursorActive = false;
            mixer.height = 100;
            tryVerify(() => row.slider.mapToItem(scroll, 0, 0).y >= -0.5
                && row.slider.mapToItem(scroll, 0, row.slider.height).y <= scroll.height + 0.5);
            mixer.outputs = [{id:"extra",label:"New device",current:false}, {id:"a",label:"Speakers",current:true}];
            tryVerify(() => row.slider.mapToItem(scroll, 0, row.slider.height).y <= scroll.height + 0.5);
            verify(row.slider.activeFocus);
        }
        function test_mixerPanelCursorNameAndKeyboardTooltip() {
            const mixer = make(mixerFactory);
            mixer.panelNavigation = true; mixer.reset(); mixer.setCursor("output", -1);
            const keyboard = child(mixer, "audioPanelKeys");
            verify(keyboard.Accessible.name.indexOf("Output") >= 0);
            verify(keyboard.Accessible.name.indexOf("64%") >= 0);
            mixer.setCursor("input", 0);
            verify(keyboard.Accessible.name.indexOf("Microphone") >= 0);
            mixer.setCursor("header", -1);
            const tooltip = child(mixer, "audioMasterTooltip");
            tryCompare(tooltip, "visible", true);
        }
    }
}
