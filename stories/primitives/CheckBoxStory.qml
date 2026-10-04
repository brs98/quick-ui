pragma ComponentBehavior: Bound
import QtQuick
import "../../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    property bool localChecked: root.args.checked === true
    property int localState: root.args.partial ? Qt.PartiallyChecked : root.args.checked ? Qt.Checked : Qt.Unchecked
    property var selections: [true, false]
    signal eventRaised(string name, var payload)
    implicitWidth: root.args.multiline || root.args.description || root.args.selectAll ? 300 : control.implicitWidth
    implicitHeight: control.implicitHeight + (choices.visible ? choices.implicitHeight + tokens.spacing : 0)
    UI.Theme { id: tokens; dark: root.dark }
    UI.CheckBox {
        id: control
        width: parent.width
        theme: tokens
        text: root.args.selectAll ? "Select all notifications" : root.args.text ?? "Start on login"
        description: root.args.description ?? ""
        multiline: root.args.multiline === true
        invalid: root.args.invalid === true
        size: root.args.size ?? "default"
        tristate: root.args.tristate === true || root.args.selectAll === true
        checkState: root.args.selectAll ? (root.selections.every(Boolean) ? Qt.Checked : root.selections.some(Boolean) ? Qt.PartiallyChecked : Qt.Unchecked)
            : root.args.tristate ? root.localState : root.localChecked ? Qt.Checked : Qt.Unchecked
        nextCheckState: function() {
            if (root.args.selectAll) return checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked;
            return tristate ? (checkState + 1) % 3 : checked ? Qt.Unchecked : Qt.Checked;
        }
        enabled: root.args.disabled !== true
        onClicked: {
            root.localChecked = checked;
            root.localState = checkState;
            if (root.args.selectAll) root.selections = [checked, checked];
            root.eventRaised("toggled", {checked: checked, checkState: checkState});
        }
    }
    Column {
        id: choices
        visible: root.args.selectAll === true
        anchors.top: control.bottom
        anchors.topMargin: tokens.spacing
        x: tokens.padding
        width: parent.width - x
        spacing: tokens.spacing
        Repeater {
            model: ["Desktop notifications", "Sound notifications"]
            UI.CheckBox {
                required property int index
                required property string modelData
                width: choices.width
                theme: tokens
                text: modelData
                checked: root.selections[index]
                enabled: root.args.disabled !== true
                onToggled: {
                    const next = root.selections.slice(); next[index] = checked; root.selections = next;
                    root.eventRaised("selectionChanged", {selected: next});
                }
            }
        }
    }
    onArgsChanged: {
        localChecked = args.checked === true;
        localState = args.partial ? Qt.PartiallyChecked : args.checked ? Qt.Checked : Qt.Unchecked;
        selections = [true, false];
    }
}
