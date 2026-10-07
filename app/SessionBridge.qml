import QtQuick
import Quickshell
import Quickshell.Io

// Kept outside Explorer so plain Qt previews never touch the filesystem.
QtObject {
    id: root
    required property SessionState state
    readonly property bool enabled: Quickshell.env("QUICKBOOK_NO_PERSIST") !== "1"
    property string error: ""
    property string revision: ""
    property string saved: ""
    property string request: ""
    property string operation: ""
    property string writing: ""
    property bool closing: false
    property bool reloading: false
    property bool received: false
    signal closeReady()

    function run(action, payload) {
        if (worker.running) return false;
        operation = action;
        request = JSON.stringify(Object.assign({action: action, revision: revision}, payload || {}));
        received = false;
        worker.stdinEnabled = true;
        worker.exec(["python3", "-B", decodeURIComponent(Qt.resolvedUrl("session_store.py").toString().replace(/^file:\/\//, ""))]);
        deadline.restart();
        return true;
    }
    function flush() {
        if (!enabled || !state.ready || error || saved === state.snapshot) {
            if (closing && !worker.running) closeReady();
            return;
        }
        if (worker.running) return;
        writing = state.snapshot;
        run("save", {data: JSON.parse(writing)});
    }
    function reload() { reloading = true; close(); }
    function close() { closing = true; debounce.stop(); flush(); }
    function recover() { if (!worker.running) run("recover"); }
    function accept(raw) {
        received = true;
        deadline.stop();
        try {
            const response = JSON.parse(raw);
            if (!response.ok) throw new Error(response.error || "State operation failed");
            revision = response.revision;
            error = "";
            if (operation === "load") {
                state.restore(response.data);
                saved = state.snapshot;
                state.ready = true;
            } else if (operation === "recover") {
                state.designs = [];
                state.ready = true;
                saved = "";
                state.notice = "Original state backed up. Saving a fresh session.";
            } else saved = writing;
        } catch (exception) {
            error = "Quickbook could not save or restore your session: " + String(exception.message || exception) + " Original state is preserved.";
        }
        settle.restart();
    }
    Component.onCompleted: {
        state.enabled = enabled;
        if (enabled) run("load");
        else state.ready = true;
    }
    property Connections changes: Connections {
        target: root.state
        function onSnapshotChanged() { if (root.state.ready && root.enabled) root.debounce.restart(); }
        function onRecoverRequested() { root.recover(); }
    }
    property Timer debounce: Timer { interval: 400; onTriggered: root.flush() }
    property Timer settle: Timer {
        interval: 20
        onTriggered: {
            if (root.worker.running) { restart(); return; }
            if (root.closing || root.operation === "recover") root.flush();
            else if (root.state.ready && root.saved !== root.state.snapshot && !root.error) root.debounce.restart();
        }
    }
    property Timer deadline: Timer {
        interval: 5000
        onTriggered: {
            if (root.worker.running) root.worker.signal(9);
            root.error = "Quickbook state operation timed out. Original state is preserved.";
            root.settle.restart();
        }
    }
    property Process worker: Process {
        onStarted: { write(root.request + "\n"); stdinEnabled = false; }
        stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.accept(text) }
        stderr: StdioCollector { waitForEnd: true }
        // qmllint disable signal-handler-parameters
        onExited: exitCode => {
            if (exitCode !== 0 && !root.received) {
                root.error = "Quickbook state helper failed. Original state is preserved.";
                root.deadline.stop(); root.settle.restart();
            }
        }
        // qmllint enable signal-handler-parameters
    }
}
