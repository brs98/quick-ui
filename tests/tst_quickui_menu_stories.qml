import QtQuick
import QtTest
import "../stories/primitives" as Stories

Item {
    width: 900
    height: 720
    Component { id: menuFactory; Stories.MenuStory { x: 20; y: 20 } }
    Component { id: itemFactory; Stories.MenuItemStory { x: 20; y: 20 } }
    Component { id: separatorFactory; Stories.MenuSeparatorStory { x: 20; y: 20 } }
    SignalSpy { id: events; signalName: "eventRaised" }

    TestCase {
        name: "QuickUIMenuStories"
        when: windowShown
        function init() { failOnWarning(/.*/); events.clear(); }
        function cleanup() { events.target = null; }
        function make(factory, properties) {
            const story = createTemporaryObject(factory, parent, properties || {});
            verify(story !== null);
            return story;
        }
        function click(item) { mouseClick(item, item.width / 2, item.height / 2); }
        function open(story) {
            click(story.trigger);
            tryCompare(story.control, "visible", true);
            waitForRendering(story.control.contentItem);
        }
        function test_nativeKeyboardSkipAndCheck() {
            const story = make(menuFactory);
            events.target = story;
            story.trigger.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Space);
            tryCompare(story.control, "visible", true);
            keyClick(Qt.Key_Down);
            compare(story.control.currentIndex, 0);
            keyClick(Qt.Key_Down);
            compare(story.control.currentIndex, 3, "Disabled row and separator are skipped");
            keyClick(Qt.Key_Space);
            tryCompare(story.control, "visible", false);
            compare(story.notifications, false);
            compare(events.count, 1);
            compare(events.signalArguments[0][0], "notificationsChanged");
            compare(events.signalArguments[0][1].checked, false);
        }
        function test_pointerDisabledDestructiveAndReset() {
            const story = make(menuFactory);
            events.target = story;
            open(story);
            click(story.control.itemAt(1));
            compare(events.count, 0);
            verify(story.control.visible);
            click(story.control.itemAt(6));
            compare(events.count, 1);
            compare(events.signalArguments[0][0], "deleteRequested");
            tryCompare(story.control, "visible", false);
            open(story);
            click(story.control.itemAt(3));
            compare(story.notifications, false);
            open(story);
            story.args = {checked: true, choice: "Compact"};
            compare(story.notifications, true);
            compare(story.arrangement, "Compact");
            tryCompare(story.control, "visible", false);
            compare(story.control.itemAt(3).checked, true);
        }
        function test_submenuRadioAndReset_data() {
            return [{tag: "ltr", rtl: false}, {tag: "rtl", rtl: true}];
        }
        function test_submenuRadioAndReset(data) {
            const story = make(menuFactory, {args: {rtl: data.rtl}});
            events.target = story;
            open(story);
            const submenu = story.control.menuAt(4);
            verify(submenu !== null);
            compare(story.control.mirrored, data.rtl);
            story.control.currentIndex = 4;
            story.control.itemAt(4).forceActiveFocus(Qt.TabFocusReason);
            keyClick(data.rtl ? Qt.Key_Left : Qt.Key_Right);
            tryCompare(submenu, "visible", true);
            click(submenu.itemAt(0));
            compare(story.arrangement, "Compact");
            compare(submenu.itemAt(0).checked, true);
            compare(submenu.itemAt(1).checked, false);
            compare(events.signalArguments[0][0], "arrangementChanged");
            story.args = {rtl: data.rtl, choice: "Comfortable"};
            compare(story.arrangement, "Comfortable");
            compare(submenu.itemAt(0).checked, false);
            compare(submenu.itemAt(1).checked, true);
            tryCompare(submenu, "visible", false);
        }
        function test_standaloneItemInteractionAndReset() {
            const story = make(itemFactory, {args: {checkable: true, checked: true}});
            events.target = story;
            mouseMove(story.control, story.control.width / 2, story.control.height / 2);
            tryCompare(story.control, "highlighted", true);
            mouseMove(parent, parent.width - 1, parent.height - 1);
            tryCompare(story.control, "highlighted", false);
            story.control.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Space);
            compare(story.localChecked, false);
            compare(events.count, 1);
            compare(events.signalArguments[0][0], "triggered");
            story.args = {checkable: true, checked: true, disabled: true};
            compare(story.control.checked, true);
            click(story.control);
            compare(events.count, 1);
        }
        function test_partialItemClearsAndResets() {
            const story = make(itemFactory, {args: {checkable: true, partial: true}});
            compare(story.control.partiallyChecked, true);
            click(story.control);
            compare(story.control.checked, true);
            compare(story.control.partiallyChecked, false);
            story.args = {checkable: true, partial: true, text: "Select all"};
            compare(story.control.checked, false);
            compare(story.control.partiallyChecked, true);
        }
        function test_largeTextAndSeparator() {
            const story = make(menuFactory, {dark: false, args: {density: "comfortable", fontScale: 1.5, rtl: true}});
            open(story);
            compare(story.control.theme.dark, false);
            compare(story.control.theme.fontScale, 1.5);
            verify(story.control.itemAt(0).height >= story.control.theme.controlHeight);
            verify(story.control.itemAt(0).mirrored);
            compare(findChild(story.control.itemAt(0), "menuLabel").effectiveHorizontalAlignment, Text.AlignRight);
            story.control.close();
            const separatorStory = make(separatorFactory, {args: {density: "compact"}});
            verify(separatorStory.control.width > 0 && separatorStory.control.height > 0);
            compare(separatorStory.control.activeFocusOnTab, false);
        }
    }
}
