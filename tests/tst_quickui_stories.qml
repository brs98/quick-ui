import QtQuick
import QtTest
import "../app"
import "../stories/primitives" as Stories

Item {
    width: 1320
    height: 840
    Stories.Catalog { id: primitiveCatalog }
    Component { id: factory; Explorer { width: 1320; height: 840; catalog: primitiveCatalog.entries } }
    TestCase {
        name: "QuickUIStories"
        when: windowShown
        property var explorer
        function init() {
            failOnWarning(/.*/);
            explorer = createTemporaryObject(factory, parent);
            verify(explorer !== null);
        }
        function test_presets_data() {
            const rows = [];
            primitiveCatalog.entries.forEach((entry, storyIndex) => entry.presets.forEach((preset, presetIndex) => {
                [true, false].forEach(dark => rows.push({tag: entry.id + "/" + preset.name + "/" + dark, storyIndex, presetIndex, dark}));
            }));
            return rows;
        }
        function test_presets(data) {
            explorer.explorerState.select(data.storyIndex);
            explorer.explorerState.preset(data.presetIndex);
            explorer.explorerState.dark = data.dark;
            tryCompare(explorer.preview, "status", Loader.Ready);
            compare(explorer.preview.item.dark, data.dark);
            compare(JSON.stringify(explorer.preview.item.args), JSON.stringify(primitiveCatalog.entries[data.storyIndex].presets[data.presetIndex].args));
            verify(waitForRendering(explorer.preview.item));
            const shot = grabImage(explorer.preview.item);
            verify(shot.width > 0 && shot.height > 0);
        }
        function test_editAndReset_data() {
            return [
                {tag: "switch", id: "ui-switch", property: "checked", value: false, key: Qt.Key_Space, event: "toggled"},
                {tag: "checkbox", id: "ui-checkbox", property: "checked", value: false, key: Qt.Key_Space, event: "toggled"},
                {tag: "slider", id: "ui-slider", property: "value", value: 60, key: Qt.Key_Right, event: "moved"},
                {tag: "select", id: "ui-select", property: "currentIndex", value: 0, key: Qt.Key_Down, event: "activated"},
                {tag: "text-field", id: "ui-text-field", property: "text", value: "", key: Qt.Key_A, event: "textEdited"}
            ];
        }
        function test_editAndReset(data) {
            verify(explorer.explorerState.selectId(data.id));
            tryCompare(explorer.preview, "status", Loader.Ready);
            const control = explorer.preview.item.children[0];
            compare(control[data.property], data.value);
            control.forceActiveFocus();
            keyClick(data.key);
            verify(control[data.property] !== data.value);
            compare(explorer.explorerState.events[0].name, data.event);
            explorer.explorerState.reset();
            compare(control[data.property], data.value);
        }
        function test_sharedThemeResponds() {
            verify(explorer.explorerState.selectId("ui-theme"));
            tryCompare(explorer.preview, "status", Loader.Ready);
            const card = explorer.preview.item.children[0];
            const original = String(card.theme.accent);
            verify(explorer.explorerState.setArg("palette", "Ocean"));
            compare(String(card.theme.accent), "#72dce8");
            verify(String(card.theme.accent) !== original);
            explorer.explorerState.setArg("radius", 0);
            compare(card.theme.radius, 0);
            explorer.explorerState.dark = false;
            compare(card.theme.dark, false);
        }
    }
}
