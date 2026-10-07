import QtQuick
import QtQuick.Controls.Basic as Controls
import QtTest
import "../registry/quickui" as UI

Item {
    id: fixture
    width: 800; height: 600
    Component {
        id: rowFactory
        UI.ListItem {
            width: 300
            text: "Sample item"
            description: "A useful secondary label"
            property int activations: 0
            property bool ownerSelected: false
            selected: ownerSelected
            onClicked: activations++
        }
    }
    Component {
        id: slotFactory
        UI.ListItem {
            id: row
            width: 300
            text: "Contact"
            description: "Preview"
            property int activations: 0
            property int trailingActivations: 0
            onClicked: activations++
            leading: Rectangle {
                objectName: "avatar"
                implicitWidth: 38; implicitHeight: 38; radius: 19
                color: row.theme.primary
                Accessible.ignored: true
            }
            trailing: UI.IconButton {
                objectName: "moreAction"
                theme: row.theme
                text: "⋯"
                accessibleLabel: "More contact actions"
                variant: "ghost"
                onClicked: row.trailingActivations++
            }
        }
    }
    Component {
        id: dynamicSlotFactory
        Item {
            id: owner
            width: 320; height: 200
            property var args: ({})
            UI.ListItem {
                id: row
                objectName: "dynamicRow"
                width: parent.width
                text: "Dynamic slots"
                leading: owner.args.slots === true ? leadingContent : null
                trailing: owner.args.slots === true ? trailingContent : null
            }
            Component {
                id: leadingContent
                Rectangle {
                    implicitWidth: row.theme.handleSize * 1.5
                    implicitHeight: implicitWidth
                    color: row.theme.surfaceHover
                }
            }
            Component {
                id: trailingContent
                Text {text: "3 new";font.pixelSize: row.theme.smallFontSize;color: row.descriptionColor}
            }
        }
    }
    Component {
        id: customFactory
        UI.ListItem {
            width: 280
            text: "Full article title"
            description: "Accessible article summary"
            padding: 0
            property int activations: 0
            onClicked: activations++
            contentItem: Item {
                objectName: "customContent"
                implicitWidth: 0
                implicitHeight: 92
                Text {text: "Custom article presentation"}
            }
        }
    }
    Component {
        id: mirrorFactory
        Item {
            property bool rtl: true
            width: 300; height: 120
            LayoutMirroring.enabled: rtl
            LayoutMirroring.childrenInherit: true
            UI.ListItem {
                objectName: "mirroredRow"
                width: parent.width
                text: "A long title that will be elided"
                description: "Secondary text wraps in narrow rows."
                leading: Rectangle {implicitWidth: 32; implicitHeight: 32; color: "red"}
                trailing: Rectangle {implicitWidth: 20; implicitHeight: 20; color: "blue"}
            }
        }
    }
    TestCase {
        name: "QuickUIListItem"
        when: windowShown
        function init() {failOnWarning(/.*/); mouseMove(fixture, 790, 590);}
        function make(factory, properties) {
            const item = createTemporaryObject(factory, fixture, properties || {});
            verify(item); return item;
        }
        function test_nativeReleaseSpaceDisabledAndSelectionOwnership() {
            const row = make(rowFactory);
            mousePress(row, 150, row.height / 2); compare(row.activations, 0);
            mouseRelease(row, 150, row.height / 2); compare(row.activations, 1);
            verify(!row.selected); verify(!row.checked);
            row.ownerSelected = true; verify(row.selected);
            row.forceActiveFocus(Qt.TabFocusReason); verify(row.visualFocus);
            keyClick(Qt.Key_Space); compare(row.activations, 2); verify(row.selected);
            row.enabled = false; mouseClick(row); row.click(); compare(row.activations, 2);
            compare(row.opacity, row.theme.disabledOpacity);
        }
        function test_cursorAndHoverAreSeparateFromSelection() {
            const row = make(rowFactory);
            row.highlighted = true;
            compare(row.background.color, row.theme.selection);
            compare(row.foregroundColor, row.theme.selectionForeground);
            verify(!row.Accessible.selected);
            row.highlighted = false;
            mouseMove(row, 150, row.height / 2); verify(row.hovered);
            compare(row.background.color, row.theme.surfaceHover);
            row.ownerSelected = true; compare(row.background.color, row.theme.selection);
            row.ownerSelected = false; row.highlighted = true;
            mouseClick(row); verify(row.highlighted); verify(!row.selected);
        }
        function test_externalHostKeepsFocusAndAccessibility() {
            const row = make(rowFactory, {focusPolicy: Qt.NoFocus});
            fixture.forceActiveFocus(); mouseClick(row);
            verify(fixture.activeFocus); compare(row.activations, 1);
            compare(row.Accessible.role, Accessible.ListItem);
            compare(row.Accessible.name, "Sample item");
            compare(row.Accessible.description, "A useful secondary label");
            verify(row.Accessible.selectable); verify(!row.Accessible.focusable);
            row.ownerSelected = true; verify(row.Accessible.selected);
            row.click(); compare(row.activations, 2); verify(fixture.activeFocus);
        }
        function test_plainTextWrapAndLargeFontSizes_data() {
            return ["sm", "default", "lg"].map(size => ({tag:size,size:size}));
        }
        function test_plainTextWrapAndLargeFontSizes(data) {
            const row = make(rowFactory, {width:160,size:data.size,text:"<b>Long literal item title</b>",description:"A longer secondary label that must wrap to stay inside this narrow item."});
            row.theme.fontScale = 2;
            const title = findChild(row,"listTitle"), detail = findChild(row,"listDescription");
            compare(title.textFormat, Text.PlainText); compare(detail.textFormat, Text.PlainText);
            compare(title.elide, Text.ElideRight); compare(detail.wrapMode, Text.Wrap);
            verify(title.Accessible.ignored); verify(detail.Accessible.ignored);
            verify(row.height >= row.contentItem.implicitHeight + row.topPadding + row.bottomPadding);
            verify(row.height >= row.theme.heightFor(data.size));
            verify(detail.height > row.theme.smallFontSize);
            verify(detail.width >= 0 && detail.width <= row.availableWidth);
        }
        function test_slotsSizeAndNestedActionDoesNotActivateRow() {
            const row = make(slotFactory);
            const avatar = findChild(row,"avatar"), action = findChild(row,"moreAction");
            verify(avatar); verify(action);
            compare(avatar.width,38); compare(avatar.height,38);
            verify(row.height >= Math.max(avatar.height,action.height) + row.topPadding + row.bottomPadding);
            mouseClick(action); compare(row.trailingActivations,1); compare(row.activations,0);
            action.forceActiveFocus(Qt.TabFocusReason); keyClick(Qt.Key_Space);
            compare(row.trailingActivations,2); compare(row.activations,0);
            row.forceActiveFocus(Qt.TabFocusReason); keyClick(Qt.Key_Tab);
            verify(action.activeFocus,"Native Tab reaches the trailing action");
            row.width = 50;
            verify(findChild(row,"listTitle").width >= 0);
            verify(findChild(row,"listTrailing").x >= 0);
            row.trailing = null; wait(0); verify(!findChild(row,"moreAction"));
            row.leading = null; wait(0); verify(!findChild(row,"avatar"));
        }
        function test_inheritedMirroringMovesSlotsExactlyOnce() {
            const parent = make(mirrorFactory), row = findChild(parent,"mirroredRow");
            const leading = findChild(row,"listLeading"), trailing = findChild(row,"listTrailing"), title = findChild(row,"listTitle");
            verify(row.mirrored); verify(leading.x > trailing.x); compare(title.effectiveHorizontalAlignment,Text.AlignRight);
            const rtlLeadingX = leading.x;
            parent.rtl = false; verify(!row.mirrored); compare(leading.x,0); verify(trailing.x > leading.x);
            compare(title.effectiveHorizontalAlignment,Text.AlignLeft); verify(rtlLeadingX > 0);
        }
        function test_customContentUsesNativeSizingAndMetadata() {
            const row = make(customFactory);
            compare(row.contentItem.objectName,"customContent"); compare(row.height,92);
            compare(row.contentItem.width,280); compare(row.Accessible.name,"Full article title");
            verify(!findChild(row.contentItem,"listTitle")); mouseClick(row); compare(row.activations,1);
        }
        function test_dynamicSlotEnableDisableAndReenable() {
            const owner = make(dynamicSlotFactory);
            const row = findChild(owner,"dynamicRow");
            const leading = findChild(row,"listLeading"), trailing = findChild(row,"listTrailing");
            compare(leading.item,null);compare(trailing.item,null);
            for (let index=0;index<3;index++) {
                owner.args = {slots:true};
                verify(leading.item);verify(trailing.item);
                verify(leading.width>0);verify(trailing.width>0);
                row.theme.fontScale = index + 1;
                row.selected = index % 2 === 0;
                owner.args = {slots:false};
                compare(leading.item,null);compare(trailing.item,null);
            }
        }
        function test_selectedKeyboardFocusHasSeparatedRing() {
            const row = make(rowFactory);
            row.ownerSelected = true; row.forceActiveFocus(Qt.TabFocusReason);
            const ring = findChild(row,"listFocusRing");verify(ring.visible);
            compare(ring.border.color,row.theme.focus);
            verify(ring.x + ring.border.width < 0, "Focus ring is separated from selected fill");
            row.theme.dark = false;
            compare(row.background.color,row.theme.selection);
            compare(findChild(row,"listTitle").color,row.theme.selectionForeground);
            compare(findChild(row,"listDescription").color,row.theme.selectionForeground);
        }
        function test_nativeIconSourceAndLeadingOverride() {
            const row = make(rowFactory);
            row.icon.source = Qt.resolvedUrl("fixtures/presentation-icon.svg");
            row.icon.color = "transparent";
            const icon = findChild(row,"listIcon"); verify(icon.visible);
            compare(icon.icon.color,Qt.color("transparent")); compare(icon.icon.source,row.icon.source);
            compare(icon.width,row.theme.handleSize);
            row.display = Controls.AbstractButton.TextOnly; verify(!icon.visible);
            row.display = Controls.AbstractButton.IconOnly; verify(icon.visible);
            verify(!findChild(row,"listTitle").parent.visible);
        }
    }
}
