import QtQuick
import QtTest
import "../app"
import "../stories/audio" as Stories

Item {
    width: 1320
    height: 840
    Stories.Catalog { id: audioCatalog }
    Component { id: factory; Explorer { width: 1320; height: 840; catalog: audioCatalog.entries } }
    TestCase {
        name: "QuickUIAudioStories"
        when: windowShown
        property var explorer
        function init() {
            failOnWarning(/.*/);
            explorer = createTemporaryObject(factory, parent);
            verify(explorer !== null);
        }
        function select(id) {
            verify(explorer.explorerState.selectId(id));
            tryCompare(explorer.preview, "status", Loader.Ready);
            return explorer.preview.item;
        }
        function test_presets_data() {
            const rows = [];
            audioCatalog.entries.forEach((entry, storyIndex) => entry.presets.forEach((preset, presetIndex) => {
                [true, false].forEach(dark => rows.push({tag: entry.id + "/" + preset.name + "/" + dark, storyIndex, presetIndex, dark}));
            }));
            return rows;
        }
        function test_presets(data) {
            explorer.width = data.dark ? 680 : 1320;
            explorer.explorerState.select(data.storyIndex);
            explorer.explorerState.preset(data.presetIndex);
            explorer.explorerState.dark = data.dark;
            tryCompare(explorer.preview, "status", Loader.Ready);
            compare(explorer.preview.item.dark, data.dark);
            compare(JSON.stringify(explorer.preview.item.args), JSON.stringify(audioCatalog.entries[data.storyIndex].presets[data.presetIndex].args));
            verify(waitForRendering(explorer.preview.item));
            const shot = grabImage(explorer.preview.item);
            verify(shot.width > 0 && shot.height > 0);
            verify(explorer.preview.item.width <= explorer.width);
        }
        function test_tooltipHoverFocusAndDismissal() {
            mouseMove(explorer, 5, 5);
            const story = select("ui-tooltip");
            const tip = story.control;
            compare(tip.visible, false);
            mouseMove(tip.parent, tip.parent.width / 2, tip.parent.height / 2);
            tryCompare(tip.parent, "hovered", true);
            wait(100);
            compare(tip.opened, false, "Hover should respect the tooltip delay");
            tryCompare(tip, "opened", true, 1200);
            verify(tip.contentItem.paintedWidth > 0);
            mouseMove(explorer, 5, 5);
            tryCompare(tip, "opened", false);
            tip.parent.forceActiveFocus(Qt.TabFocusReason);
            tryCompare(tip, "opened", true, 1200);
            keyClick(Qt.Key_Escape);
            tryCompare(tip, "opened", false);
            mouseClick(explorer, 5, 5);
            mouseMove(tip.parent, tip.parent.width / 2, tip.parent.height / 2);
            tryCompare(tip, "opened", true, 1200);
        }
        function test_tooltipPinnedPreviewSurvivesOutsideClick() {
            const story = select("ui-tooltip");
            explorer.explorerState.setArg("show", true);
            const tip = story.control;
            tryCompare(tip, "opened", true);
            mouseClick(explorer, 20, 20);
            compare(tip.opened, true);
            explorer.explorerState.setArg("show", false);
            tryCompare(tip, "opened", false);
        }
        function test_volumeInteractionAndReset() {
            const story = select("ui-volume-control");
            compare(story.control.value, 0.6);
            story.control.slider.forceActiveFocus();
            keyClick(Qt.Key_Right);
            verify(story.control.value > 0.6);
            compare(explorer.explorerState.events[0].name, "volumeRequested");
            story.control.muteButton.forceActiveFocus();
            keyClick(Qt.Key_Space);
            compare(story.control.muted, true);
            compare(explorer.explorerState.events[0].name, "muteRequested");
            explorer.explorerState.reset();
            compare(story.control.value, 0.6);
            compare(story.control.muted, false);
        }
        function test_deviceInteractionAndReset() {
            const story = select("ui-device-item");
            compare(story.control.current, false);
            story.control.forceActiveFocus();
            keyClick(Qt.Key_Space);
            compare(story.control.current, true);
            compare(explorer.explorerState.events[0].name, "selected");
            explorer.explorerState.reset();
            compare(story.control.current, false);
        }
        function test_mixerControlledRequestsAndReset() {
            const story = select("audio-mixer");
            const mixer = story.control;
            compare(mixer.outputVolume, 0.6);
            mixer.outputVolumeRequested(0.9);
            compare(mixer.outputVolume, 0.9);
            compare(explorer.explorerState.events[0].name, "outputVolumeRequested");
            mixer.outputSelected("headphones");
            compare(mixer.outputs[1].current, true);
            compare(mixer.outputs[0].current, false);
            mixer.streamVolumeRequested("music", 1.4);
            compare(mixer.streams[0].volume, 1.4);
            mixer.streamMuteRequested("music");
            compare(mixer.streams[0].muted, true);
            mixer.allMuteRequested();
            compare(mixer.outputMuted, true);
            compare(mixer.inputMuted, true);
            explorer.explorerState.reset();
            compare(mixer.outputVolume, 0.6);
            compare(mixer.outputs[0].current, true);
            compare(mixer.outputs[1].current, false);
            compare(mixer.streams[0].volume, 0.85);
            compare(mixer.streams[0].muted, false);
            compare(mixer.outputMuted, false);
            compare(mixer.inputMuted, false);
        }
        function test_mixerKeyboardAndPresetReset() {
            const story = select("audio-mixer");
            explorer.explorerState.setArg("panelNavigation", true);
            const mixer = story.control;
            mixer.forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(mixer.outputVolume, 0.6); // First movement reveals the cursor.
            keyClick(Qt.Key_Right);
            fuzzyCompare(mixer.outputVolume, 0.65, 0.0001);
            keyClick(Qt.Key_Escape);
            compare(explorer.explorerState.events[0].name, "closeRequested");
            explorer.explorerState.preset(2); // No-device fixture replaces every local model.
            compare(mixer.hasOutput, false);
            compare(mixer.hasInput, false);
            compare(mixer.streams.length, 0);
            compare(mixer.outputVolume, 0);
        }
        function test_usageExamples_data() {
            return audioCatalog.entries.map(entry => ({tag: entry.id, usage: entry.usage}));
        }
        function test_usageExamples(data) {
            const example = data.usage.slice(data.usage.indexOf("UI.Theme {"), data.usage.indexOf("\n\nSource:"));
            const scene = Qt.createQmlObject('import QtQuick; import "../registry/quickui" as UI; Item { ' + example + ' }', parent);
            verify(scene !== null);
            if (scene.children.length) compare(String(scene.children[0].theme.accent), "#72dce8");
            scene.destroy();
        }
    }
}
