import QtQuick
import QtTest
import "../registry/quickui" as UI

Item {
    width: 300
    height: 180
    Component {
        id: factory
        UI.Switch {
            theme: UI.Theme { motionDuration: 0 }
            text: "Audio"
        }
    }
    TestCase {
        name: "QuickUISwitchGeometry"
        when: windowShown
        property var control
        function init() {
            failOnWarning(/.*/);
            control = createTemporaryObject(factory, parent);
            verify(control !== null);
        }
        function test_thumbFollowsTrackContour_data() {
            const shapes = [
                {tag: "square", radius: 0, controlHeight: 36, spacing: 8, borderWidth: 1, expectedRadius: 0},
                {tag: "small-corners", radius: 2, controlHeight: 36, spacing: 8, borderWidth: 1, expectedRadius: 1},
                {tag: "default-pill", radius: 8, controlHeight: 36, spacing: 8, borderWidth: 1, expectedRadius: 11},
                {tag: "large-radius", radius: 100, controlHeight: 36, spacing: 8, borderWidth: 1, expectedRadius: 11},
                {tag: "tall-control", radius: 8, controlHeight: 48, spacing: 6, borderWidth: 1, expectedRadius: 13},
                {tag: "compact-control", radius: 8, controlHeight: 24, spacing: 4, borderWidth: 1, expectedRadius: 7},
                {tag: "minimum-track", radius: 8, controlHeight: 20, spacing: 10, borderWidth: 1, expectedRadius: 5},
                {tag: "thicker-border", radius: 8, controlHeight: 36, spacing: 8, borderWidth: 5, expectedRadius: 8}
            ];
            const rows = [];
            for (const shape of shapes) for (const checked of [false, true])
                rows.push(Object.assign({}, shape, {tag: shape.tag + (checked ? "/checked" : "/unchecked"), checked: checked}));
            return rows;
        }
        function test_thumbFollowsTrackContour(data) {
            control.theme.radius = data.radius;
            control.theme.controlHeight = data.controlHeight;
            control.theme.spacing = data.spacing;
            control.theme.borderWidth = data.borderWidth;
            control.checked = data.checked;
            verify(waitForRendering(control));
            const track = control.indicator;
            const thumb = track.children[0];
            compare(thumb.radius, data.expectedRadius,
                "Track radius " + track.radius + ", thumb inset " + thumb.y + ": inner and outer corners must share their center");
            if (thumb.radius > 0) {
                fuzzyCompare(thumb.y + thumb.radius, track.radius, 0.001);
                const horizontalInset = data.checked ? track.width - thumb.x - thumb.width : thumb.x;
                fuzzyCompare(horizontalInset + thumb.radius, track.radius, 0.001);
            }
            verify(thumb.radius >= 0 && thumb.radius <= thumb.height / 2);
            const beforeFocus = {x: thumb.x, y: thumb.y, width: thumb.width, height: thumb.height, radius: thumb.radius};
            control.forceActiveFocus(Qt.TabFocusReason);
            compare(track.border.width, control.theme.focusWidth);
            compare(thumb.radius, beforeFocus.radius, "Keyboard focus preserves the corner contour");
            compare(thumb.x, beforeFocus.x);
            compare(thumb.y, beforeFocus.y);
            compare(thumb.width, beforeFocus.width);
            compare(thumb.height, beforeFocus.height);
            verify(waitForRendering(control));
            const image = grabImage(control);
            verify(image.width > 0 && image.height > 0);
        }
        function test_liveRadiusChange() {
            const track = control.indicator;
            const thumb = track.children[0];
            control.checked = true;
            control.theme.radius = 0;
            compare(thumb.radius, 0);
            control.theme.radius = 2;
            compare(thumb.radius, 1);
            control.theme.radius = 8;
            compare(thumb.radius, 11);
        }
    }
}
