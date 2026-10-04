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
        target: "quickbook"
        function status(): string {
            return JSON.stringify({story: explorer.explorerState.story ? explorer.explorerState.story.id : null,
                preset: explorer.explorerState.presetIndex, args: explorer.explorerState.args,
                dark: explorer.explorerState.dark, events: explorer.explorerState.events,
                loaded: explorer.preview.status === Loader.Ready,
                stories: catalog.entries.map(entry => entry.id)});
        }
        function select(id: string): bool { return explorer.explorerState.selectId(id); }
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
