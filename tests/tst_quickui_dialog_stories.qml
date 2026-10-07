import QtQuick
import QtQuick.Controls.Basic as Controls
import QtTest
import "../stories/primitives" as Stories

Item {
    width: 900; height: 720
    Component { id: editorFactory; Stories.DialogStory {} }
    Component { id: alertFactory; Stories.AlertDialogStory {} }
    SignalSpy { id: events; signalName: "eventRaised" }
    TestCase {
        name: "QuickUIDialogStories"
        when: windowShown
        function init() { failOnWarning(/.*/); events.clear(); }
        function cleanup() { events.target = null; }
        function make(factory, args) {
            const story = createTemporaryObject(factory, parent, {args: args || {}});
            verify(story !== null); events.target = story; return story;
        }
        function open(story) { mouseClick(story.trigger); tryCompare(story.control, "opened", true); }
        function test_editorSaveAndReset() {
            const story = make(editorFactory);
            open(story);
            const field = findChild(story, "workspaceName");
            verify(field); field.text = "Work workspace";
            mouseClick(story.control.standardButton(Controls.Dialog.Save));
            compare(story.savedName, "Work workspace");
            compare(events.count, 1); compare(events.signalArguments[0][0], "saved");
            open(story); field.text = "Unsaved"; keyClick(Qt.Key_Escape);
            compare(story.savedName, "Work workspace");
            story.args = {name: "Personal workspace"};
            compare(story.savedName, "Personal workspace"); verify(!story.control.visible);
        }
        function test_alertCancelConfirmAndReset() {
            const story = make(alertFactory);
            open(story); tryCompare(story.control.cancelButton, "activeFocus", true);
            keyClick(Qt.Key_Return); compare(events.count, 1);
            compare(events.signalArguments[0][0], "canceled");
            open(story); keyClick(Qt.Key_Right); keyClick(Qt.Key_Return);
            compare(events.count, 2); compare(events.signalArguments[1][0], "confirmed");
            compare(story.lastAction, "Removal requested");
            open(story); story.args = {disabled: true};
            verify(!story.control.visible); compare(story.lastAction, "No action requested");
            open(story); mouseClick(story.control.confirmButton); compare(events.count, 2);
            verify(story.control.visible);
        }
    }
}
