import QtQuick
import QtTest
import "../registry/quickui" as UI

Item {
    width: 700
    height: 500

    Component {
        id: sceneComponent
        Item {
            width: 700
            height: 500
            property alias theme: sharedTheme
            property alias button: button
            property alias iconButton: iconButton
            property alias field: field
            property alias toggle: toggle
            property alias check: check
            UI.Theme { id: sharedTheme; motionDuration: 0 }
            Column {
                spacing: 15
                UI.Button { id: button; theme: sharedTheme; text: "<b>Save</b>" }
                UI.IconButton { id: iconButton; theme: sharedTheme; text: "+"; accessibleLabel: "Add workspace" }
                UI.TextField { id: field; theme: sharedTheme; placeholderText: "Workspace name" }
                UI.Switch { id: toggle; theme: sharedTheme; text: "<b>Enabled</b>" }
                UI.CheckBox { id: check; theme: sharedTheme; text: "<b>Remember</b>" }
            }
        }
    }
    SignalSpy { id: clicks; signalName: "clicked" }
    SignalSpy { id: toggles; signalName: "toggled" }
    SignalSpy { id: edits; signalName: "textEdited" }

    TestCase {
        name: "QuickUIControls"
        when: windowShown
        property var scene

        function init() {
            failOnWarning(/.*/);
            scene = createTemporaryObject(sceneComponent, parent);
            verify(scene !== null);
            verify(waitForRendering(scene));
            clicks.clear();
            toggles.clear();
            edits.clear();
        }

        function label(item) {
            if (item.textFormat !== undefined) return item;
            for (let i = 0; i < item.children.length; ++i) {
                const found = label(item.children[i]);
                if (found) return found;
            }
            return null;
        }

        function test_nativeButtonKeyboardAndDisabled() {
            clicks.target = scene.button;
            scene.button.forceActiveFocus(Qt.TabFocusReason);
            verify(scene.button.visualFocus);
            compare(scene.button.background.border.width, scene.theme.focusWidth);
            keyClick(Qt.Key_Space);
            compare(clicks.count, 1);
            scene.button.checkable = true;
            keyClick(Qt.Key_Space);
            compare(scene.button.checked, true);
            scene.button.enabled = false;
            mouseClick(scene.button);
            keyClick(Qt.Key_Space);
            compare(clicks.count, 2);
            compare(scene.button.opacity, scene.theme.disabledOpacity);
        }

        function test_keyboardTabOrder() {
            scene.button.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Tab);
            verify(scene.iconButton.activeFocus);
            keyClick(Qt.Key_Tab);
            verify(scene.field.activeFocus);
            keyClick(Qt.Key_Tab);
            verify(scene.toggle.activeFocus);
            keyClick(Qt.Key_Tab);
            verify(scene.check.activeFocus);
        }

        function test_switchAndCheckbox_data() {
            return [{ tag: "switch", name: "toggle" }, { tag: "checkbox", name: "check" }];
        }

        function test_switchAndCheckbox(data) {
            const control = scene[data.name];
            toggles.target = control;
            control.forceActiveFocus(Qt.TabFocusReason);
            verify(control.visualFocus);
            compare(control.indicator.border.width, scene.theme.focusWidth);
            keyClick(Qt.Key_Space);
            compare(control.checked, true);
            compare(toggles.count, 1);
            mouseClick(control, control.width / 2, control.height / 2);
            compare(control.checked, false);
            compare(toggles.count, 2);
            control.enabled = false;
            mouseClick(control);
            keyClick(Qt.Key_Space);
            compare(control.checked, false);
            compare(toggles.count, 2);
        }

        function test_checkboxTristate() {
            scene.check.tristate = true;
            scene.check.forceActiveFocus();
            keyClick(Qt.Key_Space);
            compare(scene.check.checkState, Qt.PartiallyChecked);
            keyClick(Qt.Key_Space);
            compare(scene.check.checkState, Qt.Checked);
            keyClick(Qt.Key_Space);
            compare(scene.check.checkState, Qt.Unchecked);
        }

        function test_fieldEditingAndDisabled() {
            edits.target = scene.field;
            scene.field.forceActiveFocus(Qt.TabFocusReason);
            compare(scene.field.background.border.width, scene.theme.focusWidth);
            keyClick(Qt.Key_A);
            keyClick(Qt.Key_B);
            compare(scene.field.text, "ab");
            compare(edits.count, 2);
            scene.field.selectAll();
            keyClick(Qt.Key_C);
            compare(scene.field.text, "c");
            scene.field.readOnly = true;
            keyClick(Qt.Key_D);
            compare(scene.field.text, "c");
            scene.field.readOnly = false;
            scene.field.enabled = false;
            keyClick(Qt.Key_E);
            compare(scene.field.text, "c");
            compare(edits.count, 3);
        }

        function test_labelsAndAccessibleNames() {
            compare(scene.iconButton.Accessible.name, "Add workspace");
            [scene.button, scene.iconButton, scene.toggle, scene.check].forEach(control => {
                const text = label(control.contentItem);
                verify(text !== null);
                compare(text.textFormat, Text.PlainText);
            });
        }

        function test_iconButtonGlyphAndKeyboard() {
            compare(scene.iconButton.contentItem.text, "+");
            compare(scene.iconButton.width, scene.iconButton.height);
            clicks.target = scene.iconButton;
            scene.iconButton.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Space);
            compare(clicks.count, 1);
            scene.iconButton.text = "×";
            scene.iconButton.accessibleLabel = "Close workspace";
            compare(scene.iconButton.contentItem.text, "×");
            compare(scene.iconButton.Accessible.name, "Close workspace");
        }

        function test_themeAndVariants_data() {
            const rows = [];
            [true, false].forEach(dark => {
                ["primary", "secondary", "ghost", "destructive"].forEach(variant => rows.push({
                    tag: (dark ? "dark/" : "light/") + variant, dark: dark, variant: variant
                }));
            });
            return rows;
        }

        function test_themeAndVariants(data) {
            scene.theme.dark = data.dark;
            scene.button.variant = data.variant;
            compare(scene.field.color, scene.theme.foreground);
            compare(findChild(scene.toggle, "toggleLabel").color, scene.theme.foreground);
            compare(findChild(scene.check, "toggleLabel").color, scene.theme.foreground);
            if (data.variant === "primary") compare(scene.button.background.color, scene.theme.accent);
            if (data.variant === "destructive") compare(scene.button.background.color, scene.theme.destructive);
            if (data.variant === "secondary") compare(scene.button.background.color, scene.theme.surface);
            const image = grabImage(scene);
            verify(image.width > 0 && image.height > 0);
        }

        function test_sharedThemeRemainsReactive() {
            scene.theme.accent = "#2468ab";
            scene.theme.foreground = "#c0ffee";
            scene.theme.radius = 2;
            scene.theme.controlHeight = 48;
            scene.theme.fontSize = 17;
            scene.theme.disabledOpacity = 0.23;
            scene.toggle.checked = true;
            scene.check.checked = true;
            compare(scene.button.background.color, scene.theme.accent);
            compare(scene.toggle.indicator.color, scene.theme.accent);
            compare(scene.check.indicator.color, scene.theme.accent);
            compare(scene.field.color, scene.theme.foreground);
            compare(scene.button.background.radius, 2);
            compare(scene.field.background.radius, 2);
            compare(scene.button.height, 48);
            compare(scene.field.height, 48);
            compare(scene.iconButton.width, scene.iconButton.height);
            [scene.button, scene.iconButton, scene.field, scene.toggle, scene.check].forEach(control => {
                compare(control.font.pixelSize, 17);
                control.enabled = false;
                compare(control.opacity, 0.23);
            });
        }
    }
}
