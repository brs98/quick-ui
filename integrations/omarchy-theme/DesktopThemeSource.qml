// SPDX-License-Identifier: MIT
/*
MIT License

Copyright (c) 2026 brs98

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
import QtQuick
import Quickshell.Io
import "OmarchyTokens.js" as OmarchyTokens

// Optional read-only source. No process runs until enabled. Reopening the
// resolved theme on every refresh follows directory/symlink replacements.
// Missing/malformed sources clear tokens instead of showing stale host data.
QtObject {
    id: root

    property bool enabled: false
    property int refreshInterval: 1500
    property string themeDirectory: ""
    property string userShellPath: ""
    property bool querySystem: true
    readonly property bool available: enabled && result.available === true
    readonly property string error: enabled ? String(result.error || "") : ""
    readonly property string name: available ? String(result.name || "Omarchy") : ""
    readonly property var tokens: available ? OmarchyTokens.resolve(result.snapshot) : ({})
    readonly property bool loading: reader.running

    property var result: ({})
    property string requestKey: ""
    readonly property string sourceKey: JSON.stringify([themeDirectory, userShellPath, querySystem])
    property bool ready: false

    function clear(message) {
        result = {available: false, error: message || "", snapshot: {}}
    }

    function refresh() {
        if (!ready || !enabled || reader.running) return
        let command = ["python3", decodeURIComponent(Qt.resolvedUrl("read_theme.py").toString().replace(/^file:\/\//, ""))]
        if (themeDirectory) command.push("--theme-dir", themeDirectory)
        if (userShellPath) command.push("--user-shell", userShellPath)
        if (!querySystem) command.push("--no-system")
        requestKey = sourceKey
        deadline.restart()
        reader.exec(command)
    }

    function accept(raw) {
        if (!enabled || requestKey !== sourceKey) return
        try {
            const next = JSON.parse(raw)
            if (next.schemaVersion !== 1 || typeof next.available !== "boolean"
                || (next.available && (!next.snapshot || !next.snapshot.colors || !next.snapshot.style)))
                throw new Error("Invalid theme snapshot")
            result = next
        } catch (_) {
            clear("Omarchy theme reader returned an invalid snapshot")
        }
    }

    onEnabledChanged: {
        if (!enabled) {
            deadline.stop()
            if (reader.running) reader.signal(9)
            clear("")
        } else refresh()
    }
    onSourceKeyChanged: {
        clear("")
        if (reader.running) reader.signal(9)
        else refresh()
    }
    Component.onCompleted: { ready = true; refresh() }

    property Timer poller: Timer {
        interval: Math.max(250, root.refreshInterval)
        repeat: true
        running: root.enabled
        onTriggered: root.refresh()
    }
    property Timer deadline: Timer {
        interval: 4000
        onTriggered: {
            if (root.reader.running) root.reader.signal(9)
            root.clear("Omarchy theme reader timed out")
        }
    }
    property Process reader: Process {
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.deadline.stop()
                root.accept(text)
            }
        }
        stderr: StdioCollector { waitForEnd: true }
        // Quickshell's qmltypes omit the QProcess::ExitStatus enum definition.
        // qmllint disable signal-handler-parameters
        onExited: exitCode => {
            if (root.enabled && root.requestKey === root.sourceKey && exitCode !== 0)
                root.clear("Omarchy theme reader failed")
        }
        // qmllint enable signal-handler-parameters
    }
}
