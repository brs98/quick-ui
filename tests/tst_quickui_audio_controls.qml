import QtQuick
import QtTest
import "../registry/quickui" as UI

Item {
    width: 600
    height: 450
    Component {
        id: sceneComponent
        Item {
            width: 600
            height: 450
            property alias theme: tokens
            property alias device: device
            property alias volume: volume
            property alias meter: meter
            property alias tooltip: tooltip
            property bool acceptRequests: true
            UI.Theme { id: tokens; motionDuration: 0 }
            UI.DeviceItem { id: device; x: 20; y: 20; theme: tokens; text: "Speakers"; glyph: "♪" }
            UI.VolumeControl {
                id: volume
                x: 20; y: 85; width: 360
                theme: tokens; title: "Speakers"; value: 0.5
                onVolumeRequested: requested => { if (parent.acceptRequests) value = requested; }
                onMuteRequested: { if (parent.acceptRequests) muted = !muted; }
            }
            UI.LevelMeter { id: meter; x: 20; y: 220; theme: tokens; value: 0.5 }
            UI.ToolTip { id: tooltip; parent: device; theme: tokens; text: "<b>Device</b>"; delay: 0 }
        }
    }
    SignalSpy { id: volumes; signalName: "volumeRequested" }
    SignalSpy { id: mutes; signalName: "muteRequested" }
    SignalSpy { id: clicks; signalName: "clicked" }
    TestCase {
        name: "QuickUIAudioControls"
        when: windowShown
        property var scene
        function init() {
            failOnWarning(/.*/);
            scene = createTemporaryObject(sceneComponent, parent);
            verify(scene !== null);
            verify(waitForRendering(scene));
            volumes.target = scene.volume; volumes.clear();
            mutes.target = scene.volume; mutes.clear();
            clicks.target = scene.device; clicks.clear();
        }
        function test_deviceKeyboardAndState() {
            scene.device.forceActiveFocus(Qt.TabFocusReason);
            verify(scene.device.visualFocus);
            keyClick(Qt.Key_Space);
            compare(clicks.count, 1);
            compare(scene.device.current, false);
            scene.device.current = true;
            compare(scene.device.Accessible.description, "Current device");
            scene.device.cursorHighlighted = true;
            compare(scene.device.background.border.width, scene.theme.focusWidth);
            scene.device.enabled = false;
            mouseClick(scene.device);
            compare(clicks.count, 1);
        }
        function test_tabOrderAndMuteKeyboard() {
            scene.device.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Tab);
            verify(scene.volume.muteButton.activeFocus);
            keyClick(Qt.Key_Space);
            compare(mutes.count, 1);
            compare(scene.volume.muted, true);
            compare(scene.volume.muteButton.Accessible.name, "Unmute Speakers");
            keyClick(Qt.Key_Tab);
            verify(scene.volume.slider.activeFocus);
            keyClick(Qt.Key_Right);
            compare(volumes.count, 1);
            fuzzyCompare(scene.volume.value, 0.55, 0.001);
        }
        function test_controlledRequestsCanBeRejected() {
            scene.acceptRequests = false;
            mouseClick(scene.volume.muteButton);
            compare(mutes.count, 1);
            compare(scene.volume.muted, false);
            scene.volume.slider.forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(volumes.count, 1);
            compare(scene.volume.value, 0.5);
            compare(scene.volume.slider.value, 0.5);
            mouseClick(scene.volume.slider, scene.volume.slider.width * 0.8, scene.volume.slider.height / 2);
            verify(volumes.count > 1);
            compare(scene.volume.value, 0.5);
            compare(scene.volume.slider.value, 0.5);
        }
        function test_dragAndExternalUpdates() {
            const slider = scene.volume.slider;
            scene.acceptRequests = false;
            mousePress(slider, slider.width / 2, slider.height / 2);
            verify(scene.volume.dragging);
            mouseMove(slider, slider.width * 0.8, slider.height / 2, 30);
            verify(scene.volume.liveValue > 0.6);
            compare(scene.volume.value, 0.5);
            mouseRelease(slider, slider.width * 0.8, slider.height / 2);
            compare(scene.volume.dragging, false);
            compare(scene.volume.liveValue, 0.5);
            compare(slider.value, 0.5);
            scene.volume.value = 0.25;
            compare(slider.value, 0.25);
            scene.volume.maximum = 1.5;
            scene.volume.value = 1.4;
            compare(slider.value, 1.4);
        }
        function test_rightClickAndWheel() {
            const slider = scene.volume.slider;
            mouseClick(slider, slider.width / 2, slider.height / 2, Qt.RightButton);
            compare(mutes.count, 1);
            mouseWheel(slider, slider.width / 2, slider.height / 2, 0, 60);
            compare(volumes.count, 0);
            mouseWheel(slider, slider.width / 2, slider.height / 2, 0, 60);
            compare(volumes.count, 1);
            fuzzyCompare(scene.volume.value, 0.55, 0.001);
            scene.volume.value = 0.99;
            mouseWheel(slider, slider.width / 2, slider.height / 2, 0, 120);
            compare(scene.volume.value, 1);
            scene.volume.value = 0.01;
            mouseWheel(slider, slider.width / 2, slider.height / 2, 0, -120);
            compare(scene.volume.value, 0);
        }
        function test_unavailable() {
            scene.volume.available = false;
            mouseClick(scene.volume.muteButton);
            mouseClick(scene.volume.slider);
            mouseClick(scene.volume.slider, 30, 20, Qt.RightButton);
            mouseWheel(scene.volume.slider, 30, 20, 0, 120);
            compare(mutes.count, 0);
            compare(volumes.count, 0);
            compare(scene.volume.opacity, scene.theme.disabledOpacity);
        }
        function test_meterAndTheme() {
            scene.meter.value = 2;
            compare(scene.meter.boundedValue, 1);
            scene.meter.value = -1;
            compare(scene.meter.boundedValue, 0);
            scene.meter.value = NaN;
            compare(scene.meter.boundedValue, 0);
            scene.theme.dark = false;
            scene.theme.accent = "#123456";
            scene.device.cursorHighlighted = true;
            compare(scene.device.background.border.color, scene.theme.accent);
            scene.volume.showMeter = true;
            scene.volume.peak = 0.8;
            const snapshot = grabImage(scene);
            verify(snapshot.width > 0);
        }
        function test_tooltipPlainTextAndDismissal() {
            scene.tooltip.visible = true;
            tryCompare(scene.tooltip, "opened", true);
            compare(scene.tooltip.contentItem.textFormat, Text.PlainText);
            compare(scene.tooltip.contentItem.text, "<b>Device</b>");
            scene.tooltip.close();
            tryCompare(scene.tooltip, "opened", false);
        }
    }
}
