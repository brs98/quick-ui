import QtQuick

Item {
    id: root
    property Theme theme: Theme {}
    property real value: 0
    property bool muted: false
    readonly property real boundedValue: Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0
    implicitWidth: 160
    implicitHeight: 6
    Accessible.role: Accessible.ProgressBar
    Accessible.name: qsTr("Audio level")
    Accessible.description: muted ? qsTr("Muted") : Math.round(boundedValue * 100) + "%"
    Rectangle {
        anchors.fill: parent
        color: root.theme.border
        radius: height / 2
        Rectangle {
            width: parent.width * root.boundedValue
            height: parent.height
            radius: height / 2
            color: root.muted ? root.theme.mutedForeground : root.theme.accent
        }
    }
}
