import QtQml

QtObject {
    id: root
    property var entries: []
    property int selectedIndex: 0
    property int presetIndex: 0
    property var args: ({})
    property string query: ""
    property bool dark: true
    property bool grid: true
    property int viewportWidth: 0
    property int viewportHeight: 0
    property var events: []
    property bool modified: false
    readonly property var story: entries.length ? entries[selectedIndex] : null
    readonly property var filtered: entries.map((entry, index) => ({entry, index})).filter(row =>
        (row.entry.group + " " + row.entry.title).toLowerCase().includes(query.trim().toLowerCase()))

    Component.onCompleted: reset()

    onEntriesChanged: {
        selectedIndex = 0;
        reset();
    }

    function select(index) {
        if (!Number.isInteger(index) || index < 0 || index >= entries.length) return false;
        selectedIndex = index;
        presetIndex = 0;
        events = [];
        reset();
        return true;
    }

    function selectId(id) {
        return select(entries.findIndex(entry => entry.id === id));
    }

    function preset(index) {
        if (!story || !Number.isInteger(index) || index < 0 || index >= story.presets.length) return false;
        presetIndex = index;
        reset();
        return true;
    }

    function reset() {
        if (!story || !story.presets.length) {
            args = {};
            return;
        }
        if (presetIndex >= story.presets.length) presetIndex = 0;
        args = Object.assign({}, story.presets[presetIndex].args);
        modified = false;
    }

    function setArg(key, value) {
        if (!story) return false;
        const control = story.controls.find(item => item.key === key);
        if (!control) return false;
        if (control.type === "number") {
            if (typeof value !== "number" || !Number.isFinite(value)) return false;
            if (control.min !== undefined) value = Math.max(control.min, value);
            if (control.max !== undefined) value = Math.min(control.max, value);
        } else if (control.type === "boolean") {
            if (typeof value !== "boolean") return false;
        } else if (control.type === "select") {
            if (!control.options.includes(value)) return false;
        } else if (control.type === "text") {
            if (typeof value !== "string") return false;
        } else return false;
        args = Object.assign({}, args, {[key]: value});
        modified = true;
        return true;
    }

    function logEvent(name, payload) {
        events = [{name: name, payload: JSON.stringify(payload === undefined ? null : payload),
            time: Qt.formatTime(new Date(), "hh:mm:ss")}].concat(events).slice(0, 100);
    }
}
