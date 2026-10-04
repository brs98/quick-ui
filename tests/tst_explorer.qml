import QtQuick
import QtTest
import "../app"
import "../stories"

Item {
    width: 1320
    height: 840
    Catalog { id: storyCatalog }
    Component {
        id: explorerComponent
        Explorer { width: 1320; height: 840; catalog: storyCatalog.entries }
    }

    TestCase {
        name: "ExplorerIntegration"
        when: windowShown
        property var explorer
        property var state

        function init() {
            failOnWarning(/.*/);
            explorer = createTemporaryObject(explorerComponent, parent);
            verify(explorer !== null);
            state = explorer.explorerState;
            verify(state !== undefined);
            tryCompare(explorer.preview, "status", Loader.Ready);
            waitForRendering(explorer);
        }

        function descendant(item, predicate) {
            if (predicate(item)) return item;
            const children = item.children || [];
            for (let i = 0; i < children.length; ++i) {
                const found = descendant(children[i], predicate);
                if (found) return found;
            }
            return null;
        }

        function control(key, predicate) {
            const editor = descendant(explorer, item => item.spec !== undefined && item.spec.key === key);
            verify(editor !== null, "Missing control: " + key);
            const input = descendant(editor, predicate);
            verify(input !== null, "Missing input: " + key);
            return input;
        }

        function button(text, root) {
            const found = descendant(root || explorer, item => item.text === text && typeof item.clicked === "function");
            verify(found !== null, "Missing button: " + text);
            return found;
        }

        function click(item) {
            mouseClick(item, item.width / 2, item.height / 2);
        }

        function typeText(item, text) {
            item.forceActiveFocus();
            keyClick(Qt.Key_A, Qt.ControlModifier);
            keyClick(Qt.Key_Backspace);
            for (let i = 0; i < text.length; ++i) keyClick(text.charAt(i));
        }

        function test_initialStory() {
            compare(state.story.id, "action-button");
            compare(state.args.label, "Create workspace");
            compare(state.modified, false);
            compare(explorer.preview.item.args.label, state.args.label);
            verify(button("Create workspace", explorer.preview.item).enabled);
        }

        function test_everyPresetAndTheme_data() {
            const rows = [];
            storyCatalog.entries.forEach((entry, storyIndex) => {
                entry.presets.forEach((preset, presetIndex) => {
                    [true, false].forEach(dark => rows.push({
                        tag: entry.id + "/" + preset.name + "/" + (dark ? "dark" : "light"),
                        storyIndex, presetIndex, dark, args: preset.args
                    }));
                });
            });
            return rows;
        }

        function test_everyPresetAndTheme(data) {
            verify(state.select(data.storyIndex));
            verify(state.preset(data.presetIndex));
            state.dark = data.dark;
            tryCompare(explorer.preview, "status", Loader.Ready);
            compare(explorer.preview.item.dark, data.dark);
            compare(JSON.stringify(explorer.preview.item.args), JSON.stringify(data.args));
            verify(waitForRendering(explorer.preview.item));
            const image = grabImage(explorer.preview.item);
            verify(image.width > 0 && image.height > 0);
            if (data.storyIndex === 0) {
                const action = button(data.args.label, explorer.preview.item);
                compare(action.tone, data.args.tone);
                compare(action.busy, data.args.busy);
                compare(action.enabled, !data.args.disabled && !data.args.busy);
            } else {
                const card = explorer.preview.item.children[0];
                compare(card.dark, data.dark);
                if (data.storyIndex === 1) {
                    compare(card.volume, data.args.volume);
                    compare(card.muted, data.args.muted);
                    compare(card.deviceName, data.args.deviceName);
                } else {
                    compare(card.title, data.args.title);
                    compare(card.severity, data.args.severity);
                    compare(card.showAction, data.args.showAction);
                }
            }
        }

        function test_textAndBooleanControlsAndReset() {
            const field = control("label", item => typeof item.textEdited === "function");
            typeText(field, "Hello");
            compare(state.args.label, "Hello");
            compare(button("Hello", explorer.preview.item).text, "Hello");
            const toggle = control("disabled", item => typeof item.toggled === "function");
            click(toggle);
            compare(state.args.disabled, true);
            verify(!button("Hello", explorer.preview.item).enabled);
            verify(state.modified);
            click(button("Reset to preset"));
            compare(state.args.label, "Create workspace");
            compare(field.text, "Create workspace");
            compare(toggle.checked, false);
            compare(state.modified, false);
        }

        function test_searchAndSwitching() {
            const search = findChild(explorer, "storySearch");
            typeText(search, "VOLUME");
            compare(state.filtered.length, 1);
            compare(state.filtered[0].entry.id, "volume-card");
            verify(state.select(state.filtered[0].index));
            tryCompare(explorer.preview, "status", Loader.Ready);
            compare(explorer.preview.item.localVolume, 64);
            state.logEvent("temporary", {});
            state.setArg("volume", 31);
            verify(state.selectId("notification-card"));
            compare(state.events.length, 0);
            compare(state.modified, false);
            compare(state.presetIndex, 0);
            compare(state.args.title, "Your workspace is ready");
            typeText(search, "no-such-component");
            compare(state.filtered.length, 0);
            compare(state.story.id, "notification-card");
            typeText(search, "");
            compare(state.filtered.length, storyCatalog.entries.length);
        }

        function test_presetAndSelectControls() {
            const preset = descendant(explorer, item => item.model !== undefined && item.model[0] === "Primary");
            verify(preset !== null);
            preset.forceActiveFocus();
            keyClick(Qt.Key_Down);
            compare(state.presetIndex, 1);
            compare(state.args.tone, "secondary");
            compare(button("View details", explorer.preview.item).tone, "secondary");
            const tone = control("tone", item => typeof item.activated === "function");
            tone.forceActiveFocus();
            keyClick(Qt.Key_Down);
            compare(state.args.tone, "danger");
            compare(button("View details", explorer.preview.item).tone, "danger");
            click(button("Reset to preset"));
            compare(state.args.tone, "secondary");
            compare(tone.currentText, "secondary");
        }

        function test_numericControl() {
            verify(state.selectId("volume-card"));
            const field = control("volume", item => typeof item.editingFinished === "function");
            typeText(field, "42");
            keyClick(Qt.Key_Return);
            compare(state.args.volume, 42);
            compare(explorer.preview.item.localVolume, 42);
            click(button("Reset to preset"));
            compare(state.args.volume, 64);
            compare(field.text, "64");
        }

        function test_minimumWindowSize_data() {
            return [
                { tag: "volume", id: "volume-card", action: "Mute", event: "muteRequested" },
                { tag: "notification", id: "notification-card", action: "Open workspace", event: "actionRequested" }
            ];
        }

        function test_minimumWindowSize(data) {
            explorer.width = 1060;
            explorer.height = 700;
            verify(state.selectId(data.id));
            tryCompare(explorer.preview, "status", Loader.Ready);
            verify(waitForRendering(explorer));
            const action = button(data.action, explorer.preview.item);
            const frame = explorer.preview.parent;
            const bottom = action.mapToItem(frame, action.width / 2, action.height);
            verify(bottom.y <= frame.height,
                "Action bottom " + bottom.y + " exceeds clipped frame height " + frame.height);
            click(action);
            compare(state.events[0].name, data.event);
        }

        function test_narrowTiledWindow_data() {
            return [{tag: "desktop-tile", width: 687}, {tag: "minimum", width: 640}];
        }

        function test_narrowTiledWindow(data) {
            explorer.width = data.width;
            explorer.height = 894;
            verify(waitForRendering(explorer));
            verify(explorer.preview.parent.width >= 300, "Narrow tiled windows must retain a usable canvas");
            const navigation = button("Components");
            verify(navigation.visible);
            click(navigation);
            const search = findChild(explorer, "compactStorySearch");
            verify(search !== null);
            tryCompare(search, "visible", true);
            typeText(search, "volume");
            let entry = null;
            tryVerify(() => {
                entry = descendant(search.parent, item => item.objectName === "compactStoryEntry" && item.visible);
                return entry !== null;
            });
            click(entry);
            compare(state.story.id, "volume-card");
            verify(waitForRendering(explorer));
            click(button("Mute", explorer.preview.item));
            compare(state.events[0].name, "muteRequested");
        }

        function test_invalidInputsDoNotMutateState() {
            const initial = JSON.stringify(state.args);
            verify(!state.select(-1));
            verify(!state.select(1.5));
            verify(!state.selectId("missing"));
            verify(!state.preset(999));
            verify(!state.setArg("unknown", true));
            verify(!state.setArg("label", 10));
            verify(!state.setArg("disabled", "true"));
            verify(!state.setArg("tone", "invalid"));
            compare(JSON.stringify(state.args), initial);
            compare(state.modified, false);
            verify(state.selectId("volume-card"));
            verify(!state.setArg("volume", NaN));
            verify(!state.setArg("volume", Infinity));
            verify(!state.setArg("volume", "50"));
            compare(state.args.volume, 64);
            verify(state.setArg("volume", 150));
            compare(explorer.preview.item.localVolume, 100);
            verify(state.setArg("volume", -4));
            compare(explorer.preview.item.localVolume, 0);
        }

        function test_buttonEventsAndBoundedLog() {
            click(button("Create workspace", explorer.preview.item));
            compare(state.events.length, 1);
            compare(state.events[0].name, "clicked");
            compare(JSON.parse(state.events[0].payload).label, "Create workspace");
            verify(state.preset(3));
            click(button("Create workspace", explorer.preview.item));
            compare(state.events.length, 1, "Busy buttons must not emit clicks");
            for (let i = 0; i < 105; ++i) state.logEvent("event", { index: i });
            compare(state.events.length, 100);
            compare(JSON.parse(state.events[0].payload).index, 104);
            compare(JSON.parse(state.events[99].payload).index, 5);
            click(button("Clear"));
            compare(state.events.length, 0);
        }

        function test_volumeInteractionAndPresetReset() {
            verify(state.selectId("volume-card"));
            tryCompare(explorer.preview, "status", Loader.Ready);
            click(button("Mute", explorer.preview.item));
            compare(explorer.preview.item.localMuted, true);
            compare(state.events[0].name, "muteRequested");
            compare(JSON.parse(state.events[0].payload).muted, true);
            const slider = descendant(explorer.preview.item, item => typeof item.moved === "function");
            verify(slider !== null);
            slider.forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(explorer.preview.item.localVolume, 65);
            compare(state.events[0].name, "volumeRequested");
            compare(state.args.volume, 64, "Story interaction keeps the preset args unchanged");
            click(button("Reset to preset"));
            compare(explorer.preview.item.localVolume, 64);
            compare(explorer.preview.item.localMuted, false);
        }

        function test_notificationAction() {
            verify(state.selectId("notification-card"));
            tryCompare(explorer.preview, "status", Loader.Ready);
            click(button("Open workspace", explorer.preview.item));
            compare(state.events[0].name, "actionRequested");
            compare(JSON.parse(state.events[0].payload).action, "Open workspace");
        }
    }
}
