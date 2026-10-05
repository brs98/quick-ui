pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.Menu {
    id: control
    property Theme theme: Theme {}
    property string size: "default"

    // QML styling also works in Quickshell without QApplication/native menus.
    popupType: Controls.Popup.Item
    padding: Math.max(theme.borderWidth, theme.spacing / 2)
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    palette.window: theme.popup
    palette.windowText: theme.popupForeground
    palette.highlight: theme.selection
    palette.highlightedText: theme.selectionForeground
    delegate: MenuItem { theme: control.theme; size: control.size }

    contentItem: ListView {
        implicitWidth: {
            let widest = 0;
            for (let index = 0; index < control.count; index++) {
                const item = control.itemAt(index);
                if (item) widest = Math.max(widest, item.implicitWidth);
            }
            return widest;
        }
        implicitHeight: contentHeight
        model: control.contentModel
        currentIndex: control.currentIndex
        clip: true
        interactive: contentHeight > height
        Controls.ScrollIndicator.vertical: Controls.ScrollIndicator {}
    }
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.theme.spacing * 2
        color: control.theme.popup
        radius: control.theme.radius
        border.color: control.theme.border
        border.width: control.theme.borderWidth
    }
}
