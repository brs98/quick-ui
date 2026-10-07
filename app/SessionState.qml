import QtQuick

// Pure UI state; filesystem access is supplied only by the shell bridge.
QtObject {
    id: root
    required property var explorer
    property var designs: []
    property string error: ""
    property string notice: ""
    property bool ready: false
    property bool enabled: false
    readonly property string snapshot: JSON.stringify({schemaVersion: 1, session: session(), designs: designs})
    signal recoverRequested()

    function session() {
        const model = explorer.explorerState;
        return {design: explorer.presetBuilder.designSnapshot(), mode: explorer.createMode ? "create" : "components",
            story: model.story ? model.story.id : "", preset: model.presetIndex, dark: model.dark, grid: model.grid,
            viewportWidth: model.viewportWidth, viewportHeight: model.viewportHeight};
    }
    function restore(data) {
        if (!data) return;
        const saved = data.session;
        explorer.presetBuilder.restoreDesign(saved.design);
        const model = explorer.explorerState;
        if (model.selectId(saved.story)) model.preset(saved.preset);
        model.dark = saved.dark; model.grid = saved.grid;
        model.viewportWidth = saved.viewportWidth; model.viewportHeight = saved.viewportHeight;
        explorer.createMode = saved.mode === "create";
        designs = data.designs;
    }
    function validName(name, except) {
        name = name.trim();
        if (!name || name.length > 80 || /[\x00-\x1f]/.test(name)) { error = "Use a name between 1 and 80 characters."; return ""; }
        if (designs.some((row, index) => index !== except && row.name.toLowerCase() === name.toLowerCase())) {
            error = "That name is already saved. Choose another name."; return "";
        }
        return name;
    }
    function saveDesign(name) {
        if (designs.length >= 100) { error = "Remove a saved design before adding another (limit 100)."; return false; }
        const valid = validName(name, -1); if (!valid) return false;
        designs = designs.concat([{name: valid, design: explorer.presetBuilder.designSnapshot()}]);
        error = ""; notice = "Saved “" + valid + "”"; return true;
    }
    function loadDesign(index) {
        if (!Number.isInteger(index) || index < 0 || index >= designs.length) return false;
        explorer.presetBuilder.restoreDesign(designs[index].design);
        error = ""; notice = "Opened “" + designs[index].name + "”"; return true;
    }
    function renameDesign(index, name) {
        if (!Number.isInteger(index) || index < 0 || index >= designs.length) return false;
        const valid = validName(name, index); if (!valid) return false;
        designs = designs.map((row, position) => position === index ? {name: valid, design: row.design} : row);
        error = ""; notice = "Renamed saved design"; return true;
    }
    function deleteDesign(index) {
        if (!Number.isInteger(index) || index < 0 || index >= designs.length) return false;
        designs = designs.filter((row, position) => position !== index);
        error = ""; notice = "Removed saved design"; return true;
    }
}
