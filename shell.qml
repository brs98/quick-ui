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
        minimumSize: Qt.size(1060, 700)
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
            return JSON.stringify({story: explorer.state.story ? explorer.state.story.id : null,
                preset: explorer.state.presetIndex, args: explorer.state.args,
                dark: explorer.state.dark, events: explorer.state.events,
                loaded: explorer.preview.status === Loader.Ready,
                stories: catalog.entries.map(entry => entry.id)});
        }
        function select(id: string): bool { return explorer.state.selectId(id); }
        function preset(index: int): bool { return explorer.state.preset(index); }
        function control(key: string, json: string): bool {
            try { return explorer.state.setArg(key, JSON.parse(json)); }
            catch (error) { return false; }
        }
        function theme(dark: bool): void { explorer.state.dark = dark; }
        function reset(): void { explorer.state.reset(); }
        function capture(path: string): bool {
            return explorer.grabToImage(result => {
                if (result.saveToFile(path)) console.log("Saved preview: " + path);
                else console.error("Could not save preview: " + path);
            });
        }
    }
}
