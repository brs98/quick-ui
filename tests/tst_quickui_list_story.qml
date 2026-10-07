import QtQuick
import QtTest
import "../stories/primitives" as Stories

Item {
    width: 640; height: 480
    Component { id: factory; Stories.ListItemStory {} }
    SignalSpy { id: events; signalName: "eventRaised" }
    TestCase {
        name: "QuickUIListStory"
        when: windowShown
        function init() { failOnWarning(/.*/); events.clear(); }
        function cleanup() { events.target = null; }
        function test_activationAndReset() {
            const story = createTemporaryObject(factory, parent, {args: {slots: true}});
            verify(story); events.target = story;
            mouseClick(story.control);
            compare(story.localSelected, true); compare(events.count, 1);
            compare(events.signalArguments[0][0], "activated");
            story.control.forceActiveFocus(Qt.TabFocusReason); keyClick(Qt.Key_Space);
            compare(story.localSelected, false); compare(events.count, 2);
            story.args = {selected: true, disabled: true};
            compare(story.localSelected, true); mouseClick(story.control);
            compare(events.count, 2);
            story.args = {selected: false}; compare(story.control.selected, false);
        }
    }
}
