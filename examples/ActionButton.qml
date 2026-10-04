import QtQuick
import "../registry/quickui" as UI

// Compatibility wrapper for the original Quickbook example API.
UI.Button {
    id: root
    property bool dark: true
    property string tone: "primary"
    property bool busy: false

    theme: UI.Theme {
        dark: root.dark
        controlHeight: 46
        padding: 22
        radius: 12
        fontSize: 14
    }
    variant: tone === "danger" ? "destructive" : tone === "primary" ? "primary" : "secondary"
    implicitWidth: Math.max(140, implicitContentWidth + leftPadding + rightPadding)
    loading: busy
    enabled: !busy
    focusPolicy: Qt.StrongFocus
    Accessible.description: busy ? qsTr("Working…") : ""
}
