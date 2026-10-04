import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: root.args.vertical === true ? 32 : 280
    implicitHeight: root.args.vertical === true ? 160 : 32
    UI.Theme { id: tokens; dark: root.dark }
    UI.Separator {
        anchors.centerIn: parent
        theme: tokens
        semantic: root.args.semantic === true
        vertical: root.args.vertical === true
        width: vertical ? implicitWidth : parent.width
        height: vertical ? parent.height : implicitHeight
    }
}
