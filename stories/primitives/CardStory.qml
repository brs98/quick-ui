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
        ColumnLayout {
            width: card.availableWidth
            spacing: tokens.spacing
            Text { text: root.args.title ?? "Your workspace"; color: tokens.foreground; font.pixelSize: tokens.fontSize + 3; font.bold: true; textFormat: Text.PlainText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
            Text { text: root.args.description ?? "Build a shell that feels like yours."; color: tokens.mutedForeground; font.pixelSize: tokens.fontSize; textFormat: Text.PlainText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
        }
    }
}
