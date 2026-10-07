import QtQuick
import QtQuick.Controls.Basic as Controls
import QtTest
import "../registry/quickui" as UI

Item {
    id: fixture
    width: 800; height: 600
    UI.Button { id: trigger; text: "Open"; x: 5; y: 5 }
    Component { id: narrowHost; Item { width: 300; height: 580 } }
    Component {
        id: alertFactory
        UI.AlertDialog {
            title: "Remove example?"
            description: "This test uses mock data only."
            property bool rtl: false
            Binding { target: contentItem.parent; property: "LayoutMirroring.enabled"; value: rtl }
            Binding { target: contentItem.parent; property: "LayoutMirroring.childrenInherit"; value: true }
            property int acceptedCount: 0
            property int rejectedCount: 0
            onAccepted: acceptedCount++
            onRejected: rejectedCount++
        }
    }
    Component {
        id: dialogFactory
        UI.Dialog {
            title: "Edit example"
            standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel
            property alias field: field
            property int acceptedCount: 0
            property int rejectedCount: 0
            onAccepted: acceptedCount++
            onRejected: rejectedCount++
            UI.TextField { id: field; placeholderText: "Name"; text: "Initial" }
        }
    }
    TestCase {
        name: "QuickUIDialogs"
        when: windowShown
        function init() { failOnWarning(/.*/); trigger.forceActiveFocus(); }
        function make(factory) {
            const dialog = createTemporaryObject(factory, fixture);
            verify(dialog); dialog.theme.motionDuration = 0;
            return dialog;
        }
        function open(dialog) { dialog.open(); tryCompare(dialog, "opened", true); }
        function test_cancelDefaultAndRepeatedOpen() {
            const dialog = make(alertFactory);
            for (let i = 1; i <= 3; i++) {
                open(dialog);
                compare(dialog.contentItem.parent.Accessible.role, Accessible.Dialog);
                compare(dialog.contentItem.parent.Accessible.name, dialog.title);
                verify(dialog.cancelButton.activeFocus);
                keyClick(Qt.Key_Return);
                tryCompare(dialog, "visible", false);
                compare(dialog.rejectedCount, i); compare(dialog.acceptedCount, 0);
                tryCompare(trigger, "activeFocus", true);
            }
        }
        function test_explicitAcceptanceAndArrowNavigation() {
            const dialog = make(alertFactory);
            open(dialog); keyClick(Qt.Key_Right);
            verify(dialog.confirmButton.activeFocus);
            keyClick(Qt.Key_Return);
            tryCompare(dialog, "visible", false);
            compare(dialog.acceptedCount, 1); compare(dialog.rejectedCount, 0);
            open(dialog); verify(dialog.cancelButton.activeFocus);
            mouseClick(dialog.confirmButton);
            tryCompare(dialog, "visible", false);
            compare(dialog.acceptedCount, 2);
        }
        function test_escapeOutsideModalAndProgrammaticClose() {
            const dialog = make(alertFactory);
            open(dialog);
            mouseClick(trigger);
            verify(dialog.opened); verify(!trigger.activeFocus);
            keyClick(Qt.Key_Escape);
            tryCompare(dialog, "visible", false);
            compare(dialog.rejectedCount, 1); compare(dialog.acceptedCount, 0);
            open(dialog); dialog.close(); tryCompare(dialog, "visible", false);
            compare(dialog.rejectedCount, 1); compare(dialog.acceptedCount, 0);
        }
        function test_disabledConfirmTabContainment() {
            const dialog = make(alertFactory); dialog.confirmEnabled = false;
            open(dialog);
            keyClick(Qt.Key_Right); verify(!dialog.confirmButton.activeFocus);
            for (let i = 0; i < 5; i++) { keyClick(Qt.Key_Tab); verify(!trigger.activeFocus); }
            mouseClick(dialog.confirmButton); compare(dialog.acceptedCount, 0);
            dialog.confirmEnabled = true; dialog.cancelButton.forceActiveFocus();
            keyClick(Qt.Key_Tab); verify(dialog.confirmButton.activeFocus);
            keyClick(Qt.Key_Space); compare(dialog.acceptedCount, 1);
        }
        function test_composableNativeStandardButtons() {
            const dialog = make(dialogFactory);
            open(dialog);
            dialog.field.forceActiveFocus(); keyClick(Qt.Key_A);
            compare(dialog.field.text, "Initiala");
            const ok = dialog.standardButton(Controls.Dialog.Ok);
            verify(ok); compare(ok.theme, dialog.theme);
            mouseClick(ok); tryCompare(dialog, "visible", false);
            compare(dialog.acceptedCount, 1);
            open(dialog); keyClick(Qt.Key_Escape); compare(dialog.rejectedCount, 1);
            open(dialog); mouseClick(trigger); tryCompare(dialog, "visible", false);
            compare(dialog.acceptedCount, 1);
            compare(dialog.rejectedCount, 2);
        }
        function test_rightToLeftActionsAndKeyboard() {
            const dialog = make(alertFactory);
            dialog.rtl = true;
            open(dialog);
            tryVerify(() => dialog.cancelButton.x > dialog.confirmButton.x);
            verify(dialog.cancelButton.mirrored);
            keyClick(Qt.Key_Left); verify(dialog.confirmButton.activeFocus);
            keyClick(Qt.Key_Right); verify(dialog.cancelButton.activeFocus);
            keyClick(Qt.Key_Enter); compare(dialog.rejectedCount, 1);
        }
        function test_narrowLongActionsStackAndWrap() {
            const host = createTemporaryObject(narrowHost, fixture);
            verify(host);
            const dialog = createTemporaryObject(alertFactory, host);
            dialog.theme.fontScale = 2;
            dialog.confirmText = "Permanently remove the selected example";
            dialog.cancelText = "Keep the selected example";
            open(dialog);
            tryVerify(() => dialog.confirmButton.y > dialog.cancelButton.y);
            verify(dialog.confirmButton.width <= dialog.availableWidth);
            verify(dialog.confirmButton.contentItem.implicitHeight > dialog.font.pixelSize);
            verify(dialog.confirmButton.height >= dialog.confirmButton.contentItem.implicitHeight);
            compare(dialog.contentItem.parent.Accessible.description, dialog.description);
        }
        function test_themeLargeTextAndPlainContent() {
            const dialog = make(alertFactory);
            dialog.title = "<b>Plain title</b>";
            dialog.description = "<b>Plain description</b> " .repeat(60);
            dialog.theme.fontScale = 2;
            dialog.theme.dark = false;
            open(dialog);
            compare(dialog.header.children[0].textFormat, Text.PlainText);
            compare(dialog.background.color, dialog.theme.popup);
            verify(dialog.height <= fixture.height - dialog.margins * 2);
            verify(dialog.confirmButton.height >= dialog.confirmButton.implicitHeight);
            verify(dialog.contentItem.contentHeight > dialog.contentItem.height);
        }
    }
}
