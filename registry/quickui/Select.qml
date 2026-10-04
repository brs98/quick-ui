pragma ComponentBehavior: Bound
import QtQuick
import QtQml.Models
import QtQuick.Controls.Basic as Controls

Controls.ComboBox {
    id: control
    property Theme theme: Theme {}
    property string placeholderText: ""
    property bool invalid: false
    property string size: "default"
    // Empty keeps native ComboBox behavior. Missing roles are available by default.
    property string enabledRole: ""
    property bool _suppressActivationRelease: false
    property int _requestedIndex: -1
    property bool _assigningIndex: false
    // Temporarily write through the native property without discarding an owner binding.
    Binding {
        target: control
        property: "currentIndex"
        value: control._requestedIndex
        when: control._assigningIndex
        restoreMode: Binding.RestoreBinding
    }
    function activateIndex(index: int) {
        _requestedIndex = index;
        _assigningIndex = true;
        activated(index);
        _assigningIndex = false;
    }

    function optionEnabled(index: int): bool {
        if (index < 0 || index >= count) return false;
        if (!enabledRole) return true;
        const entry = (delegateModel as DelegateModel).items.get(index);
        return roleEnabled(entry.model);
    }
    function roleEnabled(row: var): bool {
        if (!enabledRole) return true;
        const value = row[enabledRole] === undefined && row.modelData ? row.modelData[enabledRole] : row[enabledRole];
        return value !== false;
    }
    function navigateTo(index: int) {
        if (index < 0 || !optionEnabled(index)) return;
        if (popup.visible) {
            for (let step = 0; highlightedIndex !== index && step < count; ++step) {
                const previous = highlightedIndex;
                if (highlightedIndex < index) incrementCurrentIndex(); else decrementCurrentIndex();
                if (highlightedIndex === previous) break;
            }
        } else if (currentIndex !== index) {
            activateIndex(index);
        }
    }
    function navigate(direction: int, edge: bool) {
        const start = edge ? (direction > 0 ? -1 : count)
            : (popup.visible ? highlightedIndex : currentIndex);
        for (let i = start + direction; i >= 0 && i < count; i += direction) {
            if (optionEnabled(i)) { navigateTo(i); return; }
        }
    }
    WheelHandler {
        enabled: control.enabledRole.length > 0 && control.wheelEnabled
        onWheel: event => {
            if (event.angleDelta.y !== 0) control.navigate(event.angleDelta.y < 0 ? 1 : -1, false);
            event.accepted = true;
        }
    }
    Keys.priority: Keys.BeforeItem
    Keys.onPressed: event => {
        if (!enabledRole) { event.accepted = false; return; }
        if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Down) {
            popup.open();
        } else if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Up) {
            popup.close();
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
            navigate(event.key === Qt.Key_Down ? 1 : -1, false);
        } else if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) {
            event.accepted = false; return;
        } else if (!editable && (event.key === Qt.Key_Home || event.key === Qt.Key_End)) {
            navigate(event.key === Qt.Key_Home ? 1 : -1, true);
        } else if (popup.visible && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)) {
            _suppressActivationRelease = true;
            if (optionEnabled(highlightedIndex)) {
                activateIndex(highlightedIndex);
                popup.close();
            }
        } else if (!editable && event.key !== Qt.Key_Space && event.text && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
            const start = popup.visible ? highlightedIndex : currentIndex;
            for (let step = 1; step <= count; ++step) {
                const i = (start + step + count) % count;
                if (optionEnabled(i) && textAt(i).toLocaleLowerCase().startsWith(event.text.toLocaleLowerCase())) {
                    navigateTo(i); break;
                }
            }
        } else { event.accepted = false; return; }
        event.accepted = true;
    }
    Keys.onReleased: event => {
        if (_suppressActivationRelease && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)) {
            _suppressActivationRelease = false;
            event.accepted = true;
        } else event.accepted = false;
    }
    contentItem: Controls.TextField {
        text: control.editable ? control.editText : control.displayText
        placeholderText: control.placeholderText
        placeholderTextColor: control.theme.mutedForeground
        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: control.selectTextByMouse
        font: control.font
        padding: 0
        color: control.theme.foreground
        selectionColor: control.theme.selection
        selectedTextColor: control.theme.selectionForeground
        verticalAlignment: Text.AlignVCenter
        background: null
        // Native autocomplete may suggest any model row. Do not accept an unavailable match.
        Keys.onPressed: event => {
            if (!control.enabledRole) { event.accepted = false; return; }
            if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Down) {
                control.popup.open(); event.accepted = true;
            } else if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Up) {
                control.popup.close(); event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
                control.navigate(event.key === Qt.Key_Down ? 1 : -1, false);
                event.accepted = true;
            } else if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) {
                event.accepted = false;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (control.popup.visible) {
                    control._suppressActivationRelease = true;
                    if (control.optionEnabled(control.highlightedIndex)) {
                        control.activateIndex(control.highlightedIndex);
                        control.popup.close();
                    }
                    event.accepted = true;
                } else {
                    const index = control.find(control.editText, Qt.MatchFixedString);
                    event.accepted = index >= 0 && !control.optionEnabled(index);
                }
            } else event.accepted = false;
        }
    }


    implicitWidth: 200
    implicitHeight: Math.max(theme.heightFor(control.size), implicitContentHeight + topPadding + bottomPadding)
    padding: theme.paddingFor(size)
    topPadding: 0
    bottomPadding: 0
    spacing: theme.spacing
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    opacity: enabled ? 1 : theme.disabledOpacity
    hoverEnabled: true

    // Native ComboBox owns editing, validation, completion, model roles and selection.
    palette.text: theme.foreground
    palette.buttonText: theme.foreground
    palette.base: theme.surface
    palette.button: theme.surface
    palette.window: theme.popup
    palette.highlight: theme.selection
    palette.highlightedText: theme.selectionForeground
    palette.dark: theme.foreground
    palette.mid: theme.border

    indicator: Text {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: (control.height - height) / 2
        text: "⌄"
        color: control.theme.mutedForeground
        font: control.font
    }

    background: Rectangle {
        color: control.down || control.hovered ? control.theme.surfaceHover : control.theme.surface
        radius: control.theme.radius
        border.color: control.invalid ? control.theme.destructive : control.visualFocus ? control.theme.focus : control.theme.border
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
    }

    delegate: Controls.ItemDelegate {
        id: option
        required property int index
        required property var model
        width: control.popup.availableWidth
        implicitHeight: Math.max(control.theme.heightFor(control.size), implicitContentHeight + topPadding + bottomPadding)
        text: model[control.textRole]
        enabled: control.roleEnabled(model)
        opacity: enabled ? 1 : control.theme.disabledOpacity
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        padding: control.theme.paddingFor(control.size)
        font: control.font
        contentItem: Text {
            text: option.text
            textFormat: Text.PlainText
            font.family: option.font.family
            font.pixelSize: option.font.pixelSize
            font.weight: option.index === control.currentIndex ? Font.DemiBold : Font.Normal
            color: option.highlighted ? control.theme.selectionForeground : control.theme.popupForeground
            leftPadding: control.mirrored ? 0 : control.theme.handleSize + control.spacing
            rightPadding: control.mirrored ? control.theme.handleSize + control.spacing : 0
            Text {
                objectName: "selectedIndicator"
                visible: option.index === control.currentIndex
                x: control.mirrored ? parent.width - width : 0
                anchors.verticalCenter: parent.verticalCenter
                text: "✓"
                color: parent.color
                font: control.font
            }
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: Math.max(0, control.theme.radius - 2)
            color: option.highlighted ? control.theme.selection
                : option.hovered ? control.theme.surfaceHover : "transparent"
        }
    }

    popup: Controls.Popup {
        y: control.height + control.theme.spacing / 2
        width: control.width
        implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 280)
        padding: 4
        topMargin: control.theme.spacing
        bottomMargin: control.theme.spacing
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollBar.vertical: Controls.ScrollBar {
                id: scrollBar
                contentItem: Rectangle {
                    implicitWidth: 4
                    implicitHeight: 24
                    radius: 2
                    color: scrollBar.pressed ? control.theme.accent : control.theme.mutedForeground
                    opacity: scrollBar.size < 1 ? 1 : 0
                }
                background: Rectangle { color: "transparent" }
            }
        }
        background: Rectangle {
            color: control.theme.popup
            radius: control.theme.radius
            border.width: control.theme.borderWidth
            border.color: control.theme.border
        }
    }
}
