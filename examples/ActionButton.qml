import QtQuick
import QtQuick.Controls.Basic

AbstractButton {
    id: root

    property bool dark: true
    property string tone: "primary"
    property bool busy: false

    implicitWidth: Math.max(140, label.implicitWidth + 44)
    implicitHeight: 46
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    enabled: !busy

    background: Rectangle {
        radius: 12
        color: {
            if (!root.enabled) return root.dark ? "#303044" : "#e0dfe9";
            if (root.tone === "primary") return root.down ? "#9480df" : root.hovered ? "#c4b4ff" : "#b4a0ff";
            if (root.tone === "danger") return root.down ? "#bb5269" : root.hovered ? "#f18a9e" : "#e9778f";
            return root.down ? (root.dark ? "#3c3b54" : "#dedbec") : root.hovered ? (root.dark ? "#33334b" : "#eae6f5") : (root.dark ? "#28283c" : "#f0edf7");
        }
        border.width: root.activeFocus ? 2 : 1
        border.color: root.activeFocus ? (root.dark ? "#eee7ff" : "#63508e") : (root.tone === "secondary" ? (root.dark ? "#414158" : "#d9d4e6") : "transparent")
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Text {
        id: label
        text: root.busy ? "Working…" : root.text
        font.pixelSize: 14
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: !root.enabled ? (root.dark ? "#79798f" : "#9290a3") : root.tone === "secondary" ? (root.dark ? "#efedf8" : "#302b42") : "#211a36"
    }
}
