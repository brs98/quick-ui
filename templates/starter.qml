import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "ui" as UI

// Copy this file to shell.qml alongside installed ui/ source.
// All interactions below are local mock state; connect services in your own shell.
ShellRoot {
    id: root
    property bool amberAccent: false
    property string lastAction: "Ready to make it yours"
    UI.Theme { id: libraryTheme }

    FloatingWindow {
        id: window
        title: "QuickUI — Your shell, your source"
        implicitWidth: 720
        implicitHeight: 800
        minimumSize: Qt.size(640, 800)
        color: libraryTheme.background

        Rectangle {
            id: page
            anchors.fill: parent
            color: libraryTheme.background
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: "QUICKUI / SOURCE COMPONENTS"
                            color: libraryTheme.accent
                            font.family: libraryTheme.fontFamily
                            font.pixelSize: 11
                            font.letterSpacing: 1.5
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "Your shell, your source."
                            color: libraryTheme.foreground
                            font.family: libraryTheme.fontFamily
                            font.pixelSize: 29
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "Twelve native components. One shared theme. Entirely yours."
                            color: libraryTheme.mutedForeground
                            font.family: libraryTheme.fontFamily
                            font.pixelSize: 13
                        }
                    }
                    UI.IconButton {
                        theme: libraryTheme
                        text: "↗"
                        accessibleLabel: "Show source ownership reminder"
                        variant: "secondary"
                        onClicked: root.lastAction = "Edit the QML in ui/ to make these components yours"
                    }
                }

                UI.Separator { theme: libraryTheme; Layout.fillWidth: true }

                UI.Card {
                    theme: libraryTheme
                    Layout.fillWidth: true
                    padding: 20
                    ColumnLayout {
                        width: parent.width
                        spacing: 16
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Appearance"
                                color: libraryTheme.foreground
                                font.family: libraryTheme.fontFamily
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                Layout.fillWidth: true
                            }
                            UI.Badge { theme: libraryTheme; text: "Shared theme"; variant: "accent" }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            UI.Switch {
                                id: darkSwitch
                                theme: libraryTheme
                                text: "Dark mode"
                                checked: libraryTheme.dark
                                onToggled: libraryTheme.dark = checked
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Accent"
                                color: libraryTheme.mutedForeground
                                font.family: libraryTheme.fontFamily
                                font.pixelSize: 13
                            }
                            UI.Button {
                                theme: libraryTheme
                                id: cycleAccentButton
                                text: "Try a new color"
                                variant: "secondary"
                                onClicked: {
                                    root.amberAccent = !root.amberAccent
                                    libraryTheme.accent = Qt.binding(() => root.amberAccent
                                        ? (libraryTheme.dark ? "#f2b880" : "#92501a")
                                        : (libraryTheme.dark ? "#b4a0ff" : "#7152cf"))
                                    root.lastAction = "Every component now shares the new accent"
                                }
                            }
                        }
                    }
                }

                UI.Card {
                    theme: libraryTheme
                    Layout.fillWidth: true
                    padding: 20
                    ColumnLayout {
                        width: parent.width
                        spacing: 14
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "A little control center"
                                color: libraryTheme.foreground
                                font.family: libraryTheme.fontFamily
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                Layout.fillWidth: true
                            }
                            UI.Badge { theme: libraryTheme; text: "Mock data" }
                        }
                        UI.Field {
                            theme: libraryTheme
                            Layout.fillWidth: true
                            label: "Workspace name"
                            UI.TextField {
                                id: workspaceName
                                theme: libraryTheme
                                Layout.fillWidth: true
                                placeholderText: "Workspace name"
                                text: "Creative space"
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20
                            Text {
                                text: "Sound output"
                                color: libraryTheme.mutedForeground
                                font.family: libraryTheme.fontFamily
                                font.pixelSize: 13
                                Layout.fillWidth: true
                            }
                            UI.Select {
                                id: output
                                theme: libraryTheme
                                model: ["Studio speakers", "Headphones", "Built-in audio"]
                                Accessible.name: "Sound output"
                                onActivated: root.lastAction = "Selected " + currentText + " (mock)"
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            Text {
                                text: "Volume"
                                color: libraryTheme.mutedForeground
                                font.family: libraryTheme.fontFamily
                                font.pixelSize: 13
                            }
                            UI.Slider {
                                id: volume
                                theme: libraryTheme
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                stepSize: 1
                                value: 64
                                Accessible.name: "Volume"
                                onMoved: root.lastAction = "Volume set to " + Math.round(value) + "% (mock)"
                            }
                            Text {
                                text: Math.round(volume.value) + "%"
                                color: libraryTheme.foreground
                                font.family: libraryTheme.fontFamily
                                font.pixelSize: 13
                                Layout.preferredWidth: 36
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            Text { text: "Brightness range"; color: libraryTheme.mutedForeground; font.pixelSize: libraryTheme.fontSize }
                            UI.RangeSlider {
                                id: brightness
                                theme: libraryTheme
                                Layout.fillWidth: true
                                from: 0; to: 100; stepSize: 5
                                first.value: 25; second.value: 75
                                firstAccessibleName: "Minimum brightness"
                                secondAccessibleName: "Maximum brightness"
                                first.onMoved: root.lastAction = "Minimum brightness: " + Math.round(first.value) + "% (mock)"
                                second.onMoved: root.lastAction = "Maximum brightness: " + Math.round(second.value) + "% (mock)"
                            }
                        }
                        UI.Separator { theme: libraryTheme; Layout.fillWidth: true }
                        UI.CheckBox {
                            id: notifications
                            theme: libraryTheme
                            text: "Allow notifications in this workspace"
                            checked: true
                            onToggled: root.lastAction = "Notifications " + (checked ? "enabled" : "paused") + " (mock)"
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    UI.Button {
                        id: applyButton
                        theme: libraryTheme
                        text: "Apply preferences"
                        onClicked: root.lastAction = "Saved preferences for " + workspaceName.text + " (mock)"
                    }
                    UI.Button {
                        theme: libraryTheme
                        text: "Reset"
                        variant: "ghost"
                        onClicked: {
                            workspaceName.text = "Creative space"
                            volume.value = 64
                            brightness.setValues(25, 75)
                            output.currentIndex = 0
                            notifications.checked = true
                            root.lastAction = "Mock preferences reset"
                        }
                    }
                    Item { Layout.fillWidth: true }
                    UI.Badge { theme: libraryTheme; text: "12 components" }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }
                Text {
                    Layout.fillWidth: true
                    text: root.lastAction
                    color: libraryTheme.mutedForeground
                    font.family: libraryTheme.fontFamily
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }
        }
    }
    Connections { target: Quickshell; function onLastWindowClosed() { Qt.quit(); } }

    // A small optional test interface; normal use needs only the controls above.
    IpcHandler {
        target: "quickui-starter"
        function status(): string {
            return JSON.stringify({dark: libraryTheme.dark, accent: libraryTheme.accent.toString(),
                buttonAccent: applyButton.theme.accent.toString(), volume: volume.value,
                output: output.currentText, notifications: notifications.checked,
                rangeMinimum: brightness.first.value, rangeMaximum: brightness.second.value,
                fieldName: workspaceName.Accessible.name,
                message: root.lastAction, width: page.width, height: page.height});
        }
        function theme(dark: bool): void { libraryTheme.dark = dark; }
        function accent(color: string): void { libraryTheme.accent = color; }
        function cycleAccent(): void { cycleAccentButton.clicked(); }
        function apply(): void { applyButton.clicked(); }
        function capture(path: string): bool {
            return page.grabToImage(result => {
                if (!result.saveToFile(path)) console.error("Could not save starter capture");
            });
        }
    }
}
