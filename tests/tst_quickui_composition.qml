import QtQuick
import QtQuick.Layouts
import QtTest
import "../registry/quickui" as UI

Item {
    width: 640; height: 600
    Component {
        id: fieldFactory
        UI.Field {
            width: 240
            label: "Workspace"
            description: "A persistent label remains visible while typing."
            requiredIndicator: true
            UI.TextField { objectName: "input"; Layout.fillWidth: true }
        }
    }
    Component {
        id: rangeFactory
        UI.RangeSlider {
            x: 30; y: 300; width: 280
            from: 0; to: 100; stepSize: 5
            first.value: 20; second.value: 80
            firstAccessibleName: "Minimum brightness"
            secondAccessibleName: "Maximum brightness"
        }
    }
    Component { id: themeFactory; UI.Theme {} }
    SignalSpy { id: moved }
    TestCase {
        name: "QuickUIComposition"
        when: windowShown
        function init() { failOnWarning(/.*/); }
        function test_fieldLabelAndFeedback() {
            const field = createTemporaryObject(fieldFactory, parent);
            verify(field !== null);
            const input = findChild(field, "input");
            compare(field.control, input);
            compare(input.Accessible.name, "Workspace");
            verify(input.Accessible.description.includes("Required"));
            const label = findChild(field, "fieldLabel");
            mouseClick(label);
            verify(input.activeFocus);
            keyClick(Qt.Key_A);
            compare(input.text, "a");
            verify(label.visible);
            const initial = field.implicitHeight;
            field.errorText = "Choose a different workspace name.";
            verify(findChild(field, "fieldError").visible);
            verify(input.Accessible.description.includes(field.errorText));
            tryVerify(() => field.implicitHeight > initial);
            field.invalid = false;
            verify(!findChild(field, "fieldError").visible);
            verify(!input.Accessible.description.includes(field.errorText));
            field.manageAccessibility = false;
            input.Accessible.name = "Custom label";
            field.label = "Changed";
            compare(input.Accessible.name, "Custom label");
        }
        function test_fieldNarrowAndLargeType() {
            const field = createTemporaryObject(fieldFactory, parent, {width: 160});
            field.theme.fontScale = 2;
            field.control.theme = field.theme;
            field.errorText = "Long validation feedback must wrap inside its field.";
            tryVerify(() => field.implicitHeight > 150);
            compare(field.control.width, field.width);
            const error = findChild(field, "fieldError");
            verify(error.y + error.height <= field.implicitHeight + 1);
        }
        function test_rangeKeyboardAndLimits() {
            const range = createTemporaryObject(rangeFactory, parent);
            verify(range !== null);
            range.first.handle.forceActiveFocus(Qt.TabFocusReason);
            verify(range.first.handle.activeFocus);
            keyClick(Qt.Key_Right);
            compare(range.first.value, 25);
            keyClick(Qt.Key_Tab);
            verify(range.second.handle.activeFocus);
            keyClick(Qt.Key_Left);
            compare(range.second.value, 75);
            range.setValues(50, 50);
            range.first.handle.forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(range.first.value, 50);
            compare(range.second.value, 50);
            compare(range.first.handle.Accessible.name, "Minimum brightness");
            compare(range.first.handle.Accessible.role, Accessible.Slider);
            compare(range.first.handle.value, range.first.value);
            compare(range.first.handle.from, 0);
            compare(range.first.handle.to, 50);
            range.first.handle.value = 40;
            compare(range.first.value, 40);
            range.first.value = 45;
            compare(range.first.handle.value, 45);
            range.enabled = false;
            keyClick(Qt.Key_Left);
            compare(range.first.value, 45);
        }
        function test_rangeMirroringAndVertical() {
            const range = createTemporaryObject(rangeFactory, parent);
            verify(range.first.handle.x < range.second.handle.x);
            range.LayoutMirroring.enabled = true;
            verify(range.first.handle.x > range.second.handle.x);
            range.orientation = Qt.Vertical;
            range.width = 50; range.height = 240;
            verify(range.first.handle.y > range.second.handle.y);
            range.first.handle.forceActiveFocus();
            keyClick(Qt.Key_Up);
            compare(range.first.value, 25);
        }
        function test_rangeAccessibleActionsNotifyOwner() {
            const range = createTemporaryObject(rangeFactory, parent);
            moved.target = range.first;
            moved.signalName = "moved";
            moved.clear();
            range.accessibleStep(true, true);
            compare(range.first.value, 25);
            compare(moved.count, 1);
            range.enabled = false;
            range.accessibleStep(true, true);
            compare(range.first.value, 25);
            compare(moved.count, 1);
        }
        function test_rangeAccessibleBoundsFollowOtherThumb() {
            const range = createTemporaryObject(rangeFactory, parent);
            compare(range.first.handle.from, 0);
            compare(range.first.handle.to, 80);
            compare(range.second.handle.from, 20);
            compare(range.second.handle.to, 100);
            range.from = 100; range.to = 0;
            range.setValues(80, 20);
            compare(range.first.handle.from, 20);
            compare(range.first.handle.to, 100);
            compare(range.second.handle.from, 0);
            compare(range.second.handle.to, 80);
            range.second.value = 10;
            compare(range.first.handle.from, 10);
        }
        function test_defaultMutedTextContrast() {
            const theme = createTemporaryObject(themeFactory, parent);
            function luminance(color) {
                const channels = [color.r, color.g, color.b].map(value => value <= 0.04045 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4));
                return channels[0] * 0.2126 + channels[1] * 0.7152 + channels[2] * 0.0722;
            }
            for (const dark of [true, false]) {
                theme.dark = dark;
                for (const surface of [theme.background, theme.surface, theme.surfaceHover]) {
                    const a = luminance(theme.mutedForeground), b = luminance(surface);
                    verify((Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05) >= 4.5);
                }
            }
        }
        function test_themeCompatibilityAndScale() {
            const theme = createTemporaryObject(themeFactory, parent);
            theme.accent = "#123456";
            compare(theme.primary, theme.accent);
            compare(theme.selection, theme.accent);
            theme.primary = "#654321";
            theme.accent = "#abcdef";
            compare(String(theme.primary), "#654321");
            compare(theme.selection, theme.accent);
            theme.density = "compact";
            compare(theme.controlHeight, 30);
            theme.fontScale = 2;
            compare(theme.fontSize, 26);
            verify(theme.handleSize >= 36);
            theme.fontSize = 17;
            theme.fontScale = 1.5;
            compare(theme.fontSize, 17);
            theme.motionDuration = 0;
            compare(theme.motionDuration, 0);
        }
    }
}
