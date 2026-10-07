import QtQuick
import Quickshell
import Quickshell.Io
import "app"
import "stories"

ShellRoot {
    id: shell
    Catalog { id: catalog }
    FloatingWindow {
        id: window
        title: "Quickbook — Component Explorer"
        implicitWidth: 1320
        implicitHeight: 840
        minimumSize: Qt.size(640, 700)
        color: "#14151c"
        Explorer {
            id: explorer
            anchors.fill: parent
            catalog: catalog.entries
            onReloadRequested: Quickshell.reload(false)
        }
    }
    Connections { target: Quickshell; function onLastWindowClosed() { Qt.quit(); } }
    IpcHandler {
        id: automation
        target: "quickbook"
        function status(): string {
            return JSON.stringify({story: explorer.explorerState.story ? explorer.explorerState.story.id : null,
                preset: explorer.explorerState.presetIndex, args: explorer.explorerState.args,
                dark: explorer.explorerState.dark, events: explorer.explorerState.events,
                loaded: explorer.createMode || explorer.preview.status === Loader.Ready,
                mode: explorer.createMode ? "create" : "components",
                width: explorer.width, height: explorer.height,
                createCode: explorer.createState.code, createConfig: explorer.createState.config,
                createLocks: explorer.createState.locks, createError: explorer.createState.error,
                stories: catalog.entries.map(entry => entry.id)});
        }
        function select(id: string): bool { explorer.createMode = false; return explorer.explorerState.selectId(id); }
        function mode(value: string): bool {
            if (value !== "create" && value !== "components") return false;
            explorer.createMode = value === "create";
            return true;
        }
        function createOption(key: string, value: string): bool { return explorer.createState.setOption(key, value); }
        function createLock(key: string): void { explorer.createState.toggleLock(key); }
        function createShuffle(): void { explorer.createState.shuffle(); }
        function createUndo(): void { explorer.createState.undo(); }
        function createReset(): void { explorer.createState.reset(); }
        function createLoad(code: string): bool { return explorer.createState.loadCode(code); }
        function createTheme(dark: bool): void { explorer.presetBuilder.dark = dark; }
        function createExport(): string { return explorer.createState.exportJson(); }
        function preset(index: int): bool { return explorer.explorerState.preset(index); }
        function control(key: string, json: string): bool {
            try { return explorer.explorerState.setArg(key, JSON.parse(json)); }
            catch (error) { return false; }
        }
        function theme(dark: bool): void { explorer.explorerState.dark = dark; }
        function reset(): void { explorer.explorerState.reset(); }
        function capture(path: string): bool {
            return explorer.grabToImage(result => {
                if (result.saveToFile(path)) console.log("Saved preview: " + path);
                else console.error("Could not save preview: " + path);
            });
        }
    }
}
