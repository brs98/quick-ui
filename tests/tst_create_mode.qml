import QtQuick
import QtTest
import "../app"
import "../stories"

Item {
    width: 1320; height: 840
    Catalog { id: storyCatalog }
    Component { id: factory; Explorer { width: 1320; height: 840; catalog: storyCatalog.entries } }
    TestCase {
        name: "CreateModeIntegration"
        when: windowShown
        property var explorer
        function init() {
            failOnWarning(/.*/);
            explorer = createTemporaryObject(factory, parent);
            verify(explorer !== null);
            tryCompare(explorer.preview, "status", Loader.Ready);
        }
        function toggleMode() {
            const button = findChild(explorer, "createModeButton");
            verify(waitForRendering(button));
            mouseClick(button, button.width / 2, button.height / 2);
        }
        function enter() {
            toggleMode();
            verify(explorer.createMode);
            verify(explorer.presetBuilder.visible);
        }
        function test_modeKeepsPresetAndStorySelection() {
            explorer.explorerState.selectId("ui-list-item");
            enter();
            compare(explorer.preview.item, null, "Stories are unloaded so their popups cannot leak into Create mode");
            const initial = explorer.createState.code;
            verify(explorer.createState.setOption("radius", "large"));
            const changed = explorer.createState.code;
            verify(changed !== initial);
            toggleMode();
            verify(!explorer.createMode);
            tryCompare(explorer.preview, "status", Loader.Ready);
            compare(explorer.explorerState.story.id, "ui-list-item");
            enter();
            compare(explorer.createState.code, changed);
        }
        function test_switchClosesStoryPopup() {
            explorer.explorerState.selectId("ui-alert-dialog");
            tryCompare(explorer.preview, "status", Loader.Ready);
            mouseClick(explorer.preview.item.trigger);
            tryCompare(explorer.preview.item.control, "opened", true);
            // Native modal intentionally blocks the header; mode changes from IPC still tear it down.
            explorer.createMode = true;
            compare(explorer.preview.item, null);
            verify(explorer.createState.setOption("density", "compact"));
        }
        function test_narrowLayout_data() { return [{tag:"minimum",width:640},{tag:"tile",width:800}]; }
        function test_narrowLayout(data) {
            explorer.width = data.width; explorer.height = 700;
            enter();
            verify(waitForRendering(explorer.presetBuilder));
            const button = findChild(explorer, "createModeButton");
            const point = button.mapToItem(explorer, button.width, button.height);
            verify(point.x <= explorer.width);
            verify(explorer.presetBuilder.width <= explorer.width);
            verify(explorer.presetBuilder.height > 400);
        }
        function test_resetIsScopedToActiveMode() {
            explorer.explorerState.setArg("text", "Story label");
            enter();
            explorer.createState.setOption("radius", "large");
            explorer.forceActiveFocus(); keyClick(Qt.Key_0, Qt.ControlModifier);
            compare(explorer.createState.config.radius, "default");
            compare(explorer.explorerState.args.text, "Story label");
            explorer.focusSearch();
            verify(!explorer.createMode);
        }
    }
}
