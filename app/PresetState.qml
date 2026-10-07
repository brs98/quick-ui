import QtQuick
import "PresetCodec.js" as Codec

QtObject {
    id: root
    property var config: Codec.defaults()
    readonly property string code: {
        try { return Codec.encode(config); } catch (exception) { return ""; }
    }
    property var locks: ({colorSource: true})
    property string error: ""
    property var history: []
    readonly property bool canUndo: history.length > 0
    readonly property int historyLimit: 50
    readonly property var options: Codec.options

    function copy(value) { return JSON.parse(JSON.stringify(value)); }
    function apply(next) {
        try {
            const encoded = Codec.encode(next);
            error = "";
            if (encoded === code) return false;
            history = history.concat([copy(config)]).slice(-historyLimit);
            config = copy(next);
            return true;
        } catch (exception) {
            error = String(exception.message || exception);
            return false;
        }
    }
    function setOption(key, value) {
        const next = copy(config);
        next[key] = value;
        try { Codec.encode(next); } catch (exception) {
            error = String(exception.message || exception);
            return false;
        }
        apply(next);
        return true;
    }
    function toggleLock(key) {
        if (!options.some(option => option.key === key)) return false;
        const next = copy(locks);
        next[key] = !next[key];
        locks = next;
        return true;
    }
    function shuffle() {
        const next = copy(config);
        for (const option of options) {
            if (locks[option.key]) continue;
            const choices = option.values.filter(choice => choice.value !== config[option.key]);
            if (choices.length > 0)
                next[option.key] = choices[Math.floor(Math.random() * choices.length)].value;
        }
        return apply(next);
    }
    function undo() {
        if (!canUndo) return false;
        config = copy(history[history.length - 1]);
        history = history.slice(0, -1);
        error = "";
        return true;
    }
    // Locks only constrain shuffling; reset and explicit edits remain available.
    function reset() { return apply(Codec.defaults()); }
    function loadCode(value) {
        try {
            const next = Codec.decode(value);
            apply(next);
            return true;
        } catch (exception) {
            error = String(exception.message || exception);
            return false;
        }
    }
    function exportJson() {
        return JSON.stringify({schemaVersion: 1, code: code, config: copy(config)}, null, 2);
    }
}
