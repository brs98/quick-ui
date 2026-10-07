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
    property bool omarchyPreview: false
    property var hostTokens: null
    property bool hostAvailable: false
    property string hostName: ""
    property string hostError: ""
    property bool followColors: true
    property bool followTypography: true
    property bool followRadius: true
    property bool followSpacing: true
    property real radiusMultiplier: 1
    property alias effectiveTheme: composedTheme
    readonly property bool compact: width < 1000
    property alias createState: state
    property alias generatedTheme: previewTheme
    property string notice: ""
    implicitWidth: 1200
    implicitHeight: 760

    PresetState { id: state }
    PresetTheme { id: previewTheme; config: state.config; dark: root.dark; systemTheme: root.systemTheme }
    UI.HostTheme {
        id: composedTheme
        presetTheme: previewTheme
        hostTokens: root.omarchyPreview && root.hostAvailable ? root.hostTokens : null
        followColors: root.followColors
        followTypography: root.followTypography
        followRadius: root.followRadius
        followSpacing: root.followSpacing
        radiusMultiplier: root.radiusMultiplier
    }
    function exportRecipe() {
        return JSON.stringify({schemaVersion: 1, kind: "quickui-omarchy", preset: state.code,
            follow: {colors: followColors, typography: followTypography, radius: followRadius, spacing: followSpacing},
            radiusMultiplier: radiusMultiplier}, null, 2);
    }
    function optionIndex(option) {
        return option.values.findIndex(choice => choice.value === state.config[option.key]);
    }
    function loadDesign(value) {
        if (String(value).trim().charAt(0) !== "{") return state.loadCode(value);
        try {
            const recipe = JSON.parse(value);
            const keys = Object.keys(recipe).sort().join(",");
            if (keys !== "follow,kind,preset,radiusMultiplier,schemaVersion" || recipe.schemaVersion !== 1 || recipe.kind !== "quickui-omarchy")
                throw new Error("Expected a QuickUI Omarchy recipe, version 1");
            if (!recipe.follow || Object.keys(recipe.follow).sort().join(",") !== "colors,radius,spacing,typography"
                || Object.values(recipe.follow).some(value => typeof value !== "boolean"))
                throw new Error("Recipe follow settings must be booleans");
            if (typeof recipe.radiusMultiplier !== "number" || !Number.isFinite(recipe.radiusMultiplier)
                || recipe.radiusMultiplier < 0 || recipe.radiusMultiplier > 2)
                throw new Error("Recipe radius multiplier must be between 0 and 2");
            if (!state.loadCode(recipe.preset)) return false;
            followColors = recipe.follow.colors;
            followTypography = recipe.follow.typography;
            followRadius = recipe.follow.radius;
            followSpacing = recipe.follow.spacing;
            radiusMultiplier = recipe.radiusMultiplier;
            omarchyPreview = true;
            return true;
        } catch (exception) {
            state.error = String(exception.message || exception);
            return false;
        }
    }
    function openCode() {
        if (loadDesign(codeInput.text)) notice = "Design opened";
    }
    function copyCode() { generatedCode.selectAll(); generatedCode.copy(); notice = root.omarchyPreview ? "Fallback code copied · Copy recipe includes Omarchy settings" : "Preset code copied"; }
    function copyJson() {
        clipboardText.text = root.omarchyPreview ? root.exportRecipe() : state.exportJson();
        clipboardText.selectAll(); clipboardText.copy();
        notice = root.omarchyPreview ? "Recipe copied · save as quickui-omarchy.json" : "JSON copied · paste into a preset file";
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
                text: root.omarchyPreview && root.hostAvailable && root.followColors ? "Following host mode" : root.dark ? "Light preview" : "Dark preview"
                enabled: !(root.omarchyPreview && root.hostAvailable && root.followColors)
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
                            UI.Button { objectName: "presetUndo"; theme: root.theme; variant: "outline"; text: root.omarchyPreview ? "Undo preset" : "Undo"; enabled: state.canUndo; onClicked: state.undo() }
                            UI.Button { objectName: "presetReset"; theme: root.theme; variant: "ghost"; text: root.omarchyPreview ? "Reset preset" : "Reset"; onClicked: state.reset() }
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
                            UI.Button { objectName: "presetCopyJson"; theme: root.theme; variant: "outline"; text: root.omarchyPreview ? "Copy recipe" : "Copy JSON"; onClicked: root.copyJson() }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            UI.TextField {
                                id: codeInput
                                objectName: "presetLoadCode"
                                theme: root.theme
                                Layout.fillWidth: true
                                placeholderText: "Paste a preset code or Omarchy recipe…"
                                Accessible.name: "Preset code or Omarchy recipe to open"
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
                    ColumnLayout {
                        Layout.fillWidth: root.compact
                        Layout.preferredWidth: root.compact ? -1 : 306
                        Layout.alignment: Qt.AlignTop
                        spacing: 18
                            UI.Card {
                                theme: root.theme
                                Layout.fillWidth: true
                                padding: 16
                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 10
                                    UI.Switch {
                                        objectName: "omarchyPreviewToggle"
                                        theme: root.theme
                                        text: "Preview with Omarchy"
                                        checked: root.omarchyPreview
                                        onToggled: root.omarchyPreview = checked
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        visible: root.omarchyPreview
                                        text: root.hostAvailable ? "Following " + (root.hostName || "your active theme") + ". Theme changes update this preview." + (root.hostError ? " " + root.hostError : "")
                                            : root.hostError ? root.hostError + ". Using preset fallback." : "Reading the active Omarchy theme…"
                                        textFormat: Text.PlainText
                                        color: root.theme.mutedForeground; font.pixelSize: 12; wrapMode: Text.Wrap
                                    }
                                    Flow {
                                        Layout.fillWidth: true
                                        visible: root.omarchyPreview
                                        spacing: 16
                                        UI.CheckBox { objectName: "followColors"; theme: root.theme; text: "Host colors"; checked: root.followColors; onToggled: root.followColors = checked }
                                        UI.CheckBox { objectName: "followTypography"; theme: root.theme; text: "Host font / scale"; checked: root.followTypography; onToggled: root.followTypography = checked }
                                        UI.CheckBox { objectName: "followRadius"; theme: root.theme; text: "Host radius"; checked: root.followRadius; onToggled: root.followRadius = checked }
                                        UI.CheckBox { objectName: "followSpacing"; theme: root.theme; text: "Host spacing"; checked: root.followSpacing; onToggled: root.followSpacing = checked }
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        visible: root.omarchyPreview && root.followRadius
                                        Text { text: "Radius × " + root.radiusMultiplier.toFixed(2); color: root.theme.foreground; font.pixelSize: 12; Layout.preferredWidth: 100 }
                                        UI.Slider {
                                            objectName: "hostRadiusMultiplier"
                                            theme: root.theme; Layout.fillWidth: true
                                            from: 0; to: 2; stepSize: 0.25; value: root.radiusMultiplier
                                            Accessible.name: "Host radius multiplier"
                                            onMoved: root.radiusMultiplier = value
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        visible: root.omarchyPreview
                                        text: "Uncheck a group to use the preset choices below. Motion always uses the preset. Copy recipe saves both the fallback preset and these follow settings."
                                        color: root.theme.mutedForeground; font.pixelSize: 12; wrapMode: Text.Wrap
                                    }
                                }
                            }
                        UI.Card {
                            theme: root.theme
                            Layout.fillWidth: true
                            padding: 16
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16
                                Text { text: root.omarchyPreview ? "Fallback and override choices" : "Style choices"; color: root.theme.foreground; font.pixelSize: 16; font.weight: Font.DemiBold }
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: root.compact && root.width >= 600 ? 2 : 1
                                    columnSpacing: 16
                                    rowSpacing: 14
                                    Repeater {
                                        model: root.omarchyPreview ? state.options.filter(option => option.key !== "colorSource") : state.options
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
                                    visible: !root.omarchyPreview && state.config.colorSource === "system"
                                    text: root.systemTheme ? "Host colors come from the injected theme. Your font, spacing, and shape choices still apply."
                                        : "Host colors need a theme supplied by your app. This preview uses the chosen fallback palette; font, spacing, and shape still apply."
                                    color: root.theme.mutedForeground
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                }
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
                            Text { text: composedTheme.dark ? "Dark" : "Light"; color: root.theme.mutedForeground; font.pixelSize: 12 }
                        }
                        PresetGallery {
                            id: gallery
                            objectName: "presetGallery"
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            theme: composedTheme
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
                            text: root.omarchyPreview ? "Save Copy recipe as quickui-omarchy.json. In an initialized project, install it using the command below. Connect the installed Omarchy source to UI.OmarchyPreset.hostTokens."
                                : "Run from your QuickUI checkout, then pass UI.PresetTheme to your components. Replace the project path with your shell's directory."
                            color: root.theme.mutedForeground; font.pixelSize: 12; wrapMode: Text.Wrap
                        }
                        UI.TextField {
                            theme: root.theme
                            Layout.fillWidth: true
                            text: root.omarchyPreview ? "./quickui omarchy install --recipe quickui-omarchy.json --cwd /path/to/project" : "./quickui init --preset " + state.code + " --cwd /path/to/project"
                            readOnly: true; selectByMouse: true; font.family: "monospace"
                            Accessible.name: "Preset installation command"
                        }
                    }
                }
            }
        }
    }
}
