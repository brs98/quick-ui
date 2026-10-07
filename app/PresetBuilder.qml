pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls
import QtQuick.Layouts
import "../registry/quickui" as UI

Item {
    id: root
    property UI.Theme theme: UI.Theme {}
    property UI.Theme systemTheme: null
    property bool dark: true
    readonly property bool compact: width < 1000
    property alias createState: state
    property alias generatedTheme: previewTheme
    property string notice: ""
    implicitWidth: 1200
    implicitHeight: 760

    PresetState { id: state }
    PresetTheme { id: previewTheme; config: state.config; dark: root.dark; systemTheme: root.systemTheme }
    function optionIndex(option) {
        return option.values.findIndex(choice => choice.value === state.config[option.key]);
    }
    function openCode() {
        if (state.loadCode(codeInput.text)) notice = "Preset opened";
    }
    function copyCode() { generatedCode.selectAll(); generatedCode.copy(); notice = "Preset code copied"; }
    function copyJson() {
        clipboardText.text = state.exportJson();
        clipboardText.selectAll(); clipboardText.copy();
        notice = "JSON copied · paste into a preset file";
    }
    TextEdit { id: clipboardText; visible: false }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.compact ? 16 : 24
        spacing: 16
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text { text: "Create your QuickUI"; color: root.theme.foreground; font.family: root.theme.fontFamily; font.pixelSize: 24; font.weight: Font.DemiBold }
                Text { Layout.fillWidth: true; text: "Shape a preset. Try it on real components. Keep the code."; color: root.theme.mutedForeground; font.family: root.theme.fontFamily; font.pixelSize: 12; wrapMode: Text.Wrap }
            }
            UI.Button {
                objectName: "presetPreviewMode"
                theme: root.theme; variant: "outline"; size: "sm"
                text: root.dark ? "Light preview" : "Dark preview"
                Accessible.description: "Change the preview color mode without changing the preset"
                onClicked: root.dark = !root.dark
            }
        }
        Controls.ScrollView {
            id: page
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true
            Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
            ColumnLayout {
                width: page.availableWidth
                spacing: 18
                UI.Card {
                    theme: root.theme
                    Layout.fillWidth: true
                    padding: 16
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            UI.Button { objectName: "presetShuffle"; theme: root.theme; text: "Shuffle"; onClicked: { state.shuffle(); root.notice = ""; } }
                            UI.Button { objectName: "presetUndo"; theme: root.theme; variant: "outline"; text: "Undo"; enabled: state.canUndo; onClicked: state.undo() }
                            UI.Button { objectName: "presetReset"; theme: root.theme; variant: "ghost"; text: "Reset"; onClicked: state.reset() }
                            Item { Layout.fillWidth: true }
                            Text { visible: !root.compact; text: "Lock the choices you want to keep"; color: root.theme.mutedForeground; font.pixelSize: 12 }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            UI.TextField {
                                id: generatedCode
                                objectName: "presetGeneratedCode"
                                theme: root.theme
                                Layout.fillWidth: true
                                text: state.code
                                readOnly: true
                                selectByMouse: true
                                Accessible.name: "Generated preset code"
                                font.family: "monospace"
                            }
                            UI.Button { objectName: "presetCopyCode"; theme: root.theme; variant: "outline"; text: "Copy code"; onClicked: root.copyCode() }
                            UI.Button { objectName: "presetCopyJson"; theme: root.theme; variant: "outline"; text: "Copy JSON"; onClicked: root.copyJson() }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            UI.TextField {
                                id: codeInput
                                objectName: "presetLoadCode"
                                theme: root.theme
                                Layout.fillWidth: true
                                placeholderText: "Open a saved preset code…"
                                Accessible.name: "Preset code to open"
                                invalid: state.error !== ""
                                onAccepted: root.openCode()
                            }
                            UI.Button { objectName: "presetOpen"; theme: root.theme; variant: "outline"; text: "Open"; onClicked: root.openCode() }
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: state.error || root.notice
                            textFormat: Text.PlainText
                            color: state.error ? root.theme.destructive : root.theme.mutedForeground
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            Accessible.role: Accessible.StaticText
                        }
                    }
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: root.compact ? 1 : 2
                    columnSpacing: 20
                    rowSpacing: 20
                    UI.Card {
                        theme: root.theme
                        Layout.fillWidth: root.compact
                        Layout.preferredWidth: root.compact ? -1 : 306
                        Layout.alignment: Qt.AlignTop
                        padding: 16
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 16
                            Text { text: "Style choices"; color: root.theme.foreground; font.pixelSize: 16; font.weight: Font.DemiBold }
                            GridLayout {
                                Layout.fillWidth: true
                                columns: root.compact && root.width >= 600 ? 2 : 1
                                columnSpacing: 16
                                rowSpacing: 14
                                Repeater {
                                    model: state.options
                                    ColumnLayout {
                                        id: optionRow
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 6
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Text { Layout.fillWidth: true; text: optionRow.modelData.label; color: root.theme.foreground; font.pixelSize: 12 }
                                            UI.Button {
                                                objectName: "presetLock-" + optionRow.modelData.key
                                                theme: root.theme; variant: "ghost"; size: "sm"
                                                text: checked ? "Locked" : "Lock"
                                                checkable: true
                                                checked: state.locks[optionRow.modelData.key] === true
                                                Accessible.name: "Lock " + optionRow.modelData.label
                                                onToggled: state.toggleLock(optionRow.modelData.key)
                                            }
                                        }
                                        UI.Select {
                                            objectName: "presetOption-" + optionRow.modelData.key
                                            theme: root.theme
                                            Layout.fillWidth: true
                                            model: optionRow.modelData.values
                                            textRole: "label"
                                            currentIndex: root.optionIndex(optionRow.modelData)
                                            Accessible.name: optionRow.modelData.label
                                            onActivated: index => state.setOption(optionRow.modelData.key, optionRow.modelData.values[index].value)
                                        }
                                    }
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: state.config.colorSource === "system"
                                text: root.systemTheme ? "Host colors come from the injected theme. Your font, spacing, and shape choices still apply."
                                    : "Host colors need a theme supplied by your app. This preview uses the chosen fallback palette; font, spacing, and shape still apply."
                                color: root.theme.mutedForeground
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Live preview"; color: root.theme.foreground; font.pixelSize: 16; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            Text { text: root.dark ? "Dark" : "Light"; color: root.theme.mutedForeground; font.pixelSize: 12 }
                        }
                        PresetGallery {
                            id: gallery
                            objectName: "presetGallery"
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            theme: previewTheme
                        }
                    }
                }
                UI.Card {
                    theme: root.theme
                    Layout.fillWidth: true
                    padding: 16
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        Text { text: "Use this preset"; color: root.theme.foreground; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Text {
                            Layout.fillWidth: true
                            text: "Run from your QuickUI checkout, then pass UI.PresetTheme to your components. Replace the project path with your shell's directory."
                            color: root.theme.mutedForeground; font.pixelSize: 12; wrapMode: Text.Wrap
                        }
                        UI.TextField {
                            theme: root.theme
                            Layout.fillWidth: true
                            text: "./quickui init --preset " + state.code + " --cwd /path/to/project"
                            readOnly: true; selectByMouse: true; font.family: "monospace"
                            Accessible.name: "Preset installation command"
                        }
                    }
                }
            }
        }
    }
}
