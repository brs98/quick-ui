import QtQuick
import QtQuick.Layouts
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: 320
    implicitHeight: card.implicitHeight
    UI.Theme { id: tokens; dark: root.dark }
    UI.Card {
        id: card
        anchors.fill: parent
        theme: tokens
        size: root.args.size ?? "default"
        // One layout owns header, body and footer; Pane measures its implicit size.
        ColumnLayout {
            width: card.availableWidth
            spacing: tokens.spacing
            Text { objectName: "cardTitle"; text: root.args.title ?? "Your workspace"; color: tokens.cardForeground; font.pixelSize: tokens.fontSize + 3; font.bold: true; textFormat: Text.PlainText; Layout.fillWidth: true; wrapMode: Text.Wrap }
            UI.Separator { theme: tokens; Layout.fillWidth: true; visible: root.args.footer !== false }
            Text { objectName: "cardDescription"; text: root.args.description ?? "Build a shell that feels like yours."; color: tokens.mutedForeground; font.pixelSize: tokens.fontSize; textFormat: Text.PlainText; Layout.fillWidth: true; wrapMode: Text.Wrap }
            GridLayout {
                visible: root.args.footer !== false
                Layout.fillWidth: true
                columns: card.availableWidth < 220 ? 1 : 2
                rowSpacing: tokens.spacing
                columnSpacing: tokens.spacing
                UI.Button {
                    theme: tokens
                    Layout.fillWidth: true
                    size: card.size
                    text: "Cancel"
                    variant: "outline"
                    onClicked: root.eventRaised("cancel", {})
                }
                UI.Button {
                    theme: tokens
                    Layout.fillWidth: true
                    size: card.size
                    text: "Continue"
                    onClicked: root.eventRaised("continue", {})
                }
            }
        }
    }
}
