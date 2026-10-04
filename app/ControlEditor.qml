pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../registry/quickui" as UI

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
        UI.TextField {
            theme: root.theme
            Accessible.name: root.spec.label
            text: String(root.value ?? "")
            onTextEdited: root.edited(text)
        }
    }
    Component {
        id: selectEditor
        UI.Select {
            theme: root.theme
            Accessible.name: root.spec.label
            model: root.spec.options
            currentIndex: root.spec.options.indexOf(root.value)
            onActivated: root.edited(currentText)
        }
    }
    Component {
        id: boolEditor
        UI.Switch {
            theme: root.theme
            Accessible.name: root.spec.label
            checked: Boolean(root.value)
            text: checked ? "True" : "False"
            onToggled: root.edited(checked)
        }
    }

    Component {
        id: numberEditor
        RowLayout {
            UI.Slider {
                theme: root.theme
                Accessible.name: root.spec.label
                id: slider
                Layout.fillWidth: true
                from: root.spec.min ?? 0
                to: root.spec.max ?? 100
                stepSize: root.spec.step ?? 1
                value: Number(root.value)
                onMoved: root.edited(value)
            }

            UI.TextField {
                Layout.preferredWidth: 58
                theme: root.theme
                Accessible.name: root.spec.label
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
