import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    required property var theme
    required property var spec
    required property var value
    signal edited(var newValue)
    spacing: 9
    RowLayout {
        Layout.fillWidth: true
        Text { text: root.spec.label; color: root.theme.text; font.pixelSize: 12; Layout.fillWidth: true }
        Text { text: root.spec.type; color: root.theme.muted; font.pixelSize: 10; font.family: "monospace" }
    }
    Loader {
        Layout.fillWidth: true
        sourceComponent: root.spec.type === "boolean" ? boolEditor : root.spec.type === "number" ? numberEditor : root.spec.type === "select" ? selectEditor : textEditor
    }
    Component {
        id: textEditor
        UiField {
            theme: root.theme
            text: String(root.value ?? "")
            onTextEdited: root.edited(text)
        }
    }
    Component {
        id: selectEditor
        UiSelect {
            theme: root.theme
            model: root.spec.options
            currentIndex: root.spec.options.indexOf(root.value)
            onActivated: root.edited(currentText)
        }
    }
    Component {
        id: boolEditor
        Switch {
            id: toggle
            checked: Boolean(root.value)
            text: checked ? "True" : "False"
            onToggled: root.edited(checked)
            contentItem: Text {
                text: toggle.text
                color: root.theme.muted
                font.pixelSize: 12
                leftPadding: 52
                verticalAlignment: Text.AlignVCenter
            }
            indicator: Rectangle {
                implicitWidth: 40
                implicitHeight: 22
                y: (toggle.height - height) / 2
                radius: 11
                color: toggle.checked ? root.theme.accent : root.theme.line
                border.color: toggle.activeFocus ? root.theme.text : color
                Rectangle {
                    x: toggle.checked ? 21 : 3; y: 3; width: 16; height: 16; radius: 8
                    color: toggle.checked ? root.theme.bg : root.theme.text
                    Behavior on x { NumberAnimation { duration: 120 } }
                }
            }
        }
    }
    Component {
        id: numberEditor
        RowLayout {
            Slider {
                id: slider
                Layout.fillWidth: true
                from: root.spec.min ?? 0
                to: root.spec.max ?? 100
                stepSize: root.spec.step ?? 1
                value: Number(root.value)
                onMoved: root.edited(value)
                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: slider.availableWidth
                    height: 4
                    radius: 2
                    color: root.theme.line
                    Rectangle { width: slider.visualPosition * parent.width; height: 4; radius: 2; color: root.theme.accent }
                }
                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: 14; height: 14; radius: 7
                    color: root.theme.accent
                    border.color: slider.activeFocus ? root.theme.text : root.theme.accent
                }
            }
            UiField {
                Layout.preferredWidth: 58
                theme: root.theme
                text: String(root.value)
                validator: DoubleValidator { bottom: root.spec.min ?? -Infinity; top: root.spec.max ?? Infinity }
                onEditingFinished: {
                    if (text.trim() && acceptableInput) root.edited(Number(text));
                    text = Qt.binding(() => String(root.value));
                }
            }
        }
    }
}
