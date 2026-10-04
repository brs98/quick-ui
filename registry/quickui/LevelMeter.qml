import QtQuick

Item {
    id: root
    property Theme theme: Theme {}
    property real value: 0
    property bool muted: false
    readonly property real boundedValue: Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0
    implicitWidth: 160
    implicitHeight: 6
    // Keep the public name/description customization point while exposing only
    // the bounded child value to Qt's numeric accessibility interface.
    Accessible.ignored: true
    Accessible.name: qsTr("Audio level")
    Accessible.description: muted ? qsTr("Muted") : Math.round(boundedValue * 100) + "%"
    Item {
        objectName: "levelMeterAccessible"
        anchors.fill: parent
        readonly property real value: root.boundedValue
        readonly property real minimumValue: 0
        readonly property real maximumValue: 1
        Accessible.role: Accessible.ProgressBar
        Accessible.name: root.Accessible.name
        Accessible.description: root.Accessible.description
    }
    Rectangle {
        id: track
        anchors.fill: parent
        color: root.theme.border
        radius: height / 2
        // Reveal part of a full-sized rounded pill. A narrow independent pill
        // has different corner geometry and paints outside the track silhouette.
        Item {
            width: parent.width * root.boundedValue
            height: parent.height
            clip: true
            Rectangle {
                width: track.width
                height: track.height
                radius: track.radius
                color: root.muted ? root.theme.mutedForeground : root.theme.accent
            }
        }
    }
}
