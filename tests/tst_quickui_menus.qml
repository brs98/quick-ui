import QtQuick
import QtQuick.Controls.Basic as Controls
import QtTest
import "../registry/quickui" as UI

Item {
    id: fixture
    width: 800; height: 600
    Component {
        id: basicFactory
        UI.Menu {
            id: menu
            x: 20; y: 20; width: 280
            property int triggeredCount: 0
            UI.MenuItem { theme: menu.theme; text: "First"; onTriggered: menu.triggeredCount++ }
            UI.MenuSeparator { theme: menu.theme }
            UI.MenuItem { theme: menu.theme; text: "Disabled"; enabled: false }
            UI.MenuItem { theme: menu.theme; text: "Last"; onTriggered: menu.triggeredCount++ }
        }
    }
    Component {
        id: actionFactory
        UI.Menu {
            id: menu
            x: 20; y: 20
            size: "lg"
            property int triggers: 0
            Controls.Action { text: "Action"; shortcut: "Ctrl+K"; checkable: true; onTriggered: menu.triggers++ }
        }
    }
    Component {
        id: submenuFactory
        UI.Menu {
            id: menu
            x: 20; y: 20; width: 200
            property int triggers: 0
            property bool rightToLeft: false
            Binding { target: menu.contentItem.parent; property: "LayoutMirroring.enabled"; value: menu.rightToLeft }
            Binding { target: menu.contentItem.parent; property: "LayoutMirroring.childrenInherit"; value: true }
            UI.MenuItem { theme: menu.theme; text: "Top" }
            UI.Menu {
                theme: menu.theme
                id: submenu
                title: "More"
                Binding { target: submenu.contentItem.parent; property: "LayoutMirroring.enabled"; value: menu.rightToLeft }
                Binding { target: submenu.contentItem.parent; property: "LayoutMirroring.childrenInherit"; value: true }
                UI.MenuItem { theme: menu.theme; text: "Nested"; onTriggered: menu.triggers++ }
            }
        }
    }
    Component {
        id: checksFactory
        UI.Menu {
            id: menu
            x: 20; y: 20
            UI.MenuItem { theme: menu.theme; text: "Check"; checkable: true }
            UI.MenuItem { theme: menu.theme; text: "One"; checkable: true; autoExclusive: true; checked: true }
            UI.MenuItem { theme: menu.theme; text: "Two"; checkable: true; autoExclusive: true }
        }
    }
    Component { id: itemFactory; UI.MenuItem { width: 340; text: "Long menu action" } }
    TestCase {
        name: "QuickUIMenus"
        when: windowShown
        function init() { failOnWarning(/.*/); mouseMove(fixture, 790, 590); }
        function make(factory) {
            const item = createTemporaryObject(factory, fixture);
            verify(item); item.theme.motionDuration = 0;
            return item;
        }
        function open(menu) { menu.open(); tryCompare(menu, "opened", true); }
        function test_nativeKeyboardSkipsAndDismisses() {
            const menu = make(basicFactory);
            compare(menu.popupType, Controls.Popup.Item);
            open(menu);
            menu.itemAt(0).forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Down);
            compare(menu.currentIndex, 3);
            keyClick(Qt.Key_Up); compare(menu.currentIndex, 0);
            keyClick(Qt.Key_Return); compare(menu.triggeredCount, 1);
            tryCompare(menu, "visible", false);
            open(menu); keyClick(Qt.Key_Escape); tryCompare(menu, "visible", false);
            open(menu); mouseClick(fixture, 780, 580); tryCompare(menu, "visible", false);
        }
        function test_keyboardMovesHighlightAwayFromStationaryPointer() {
            const menu = make(basicFactory);
            open(menu);
            const first = menu.itemAt(0);
            const last = menu.itemAt(3);
            mouseMove(first, first.width / 2, first.height / 2);
            tryCompare(first, "hovered", true);
            tryCompare(menu, "currentIndex", 0);
            keyClick(Qt.Key_Down);
            compare(menu.currentIndex, 3);
            verify(first.hovered, "Pointer remains over the previous row");
            verify(!first.hot, "Keyboard selection clears the stationary pointer row's highlight");
            verify(last.hot);
            compare(first.background.color, "#00000000");
            compare(last.background.color, menu.theme.selection);
            menu.close();
        }
        function test_nativeActionAndAutomaticDelegate() {
            const menu = make(actionFactory);
            const item = menu.itemAt(0);
            compare(item.theme, menu.theme); compare(item.size, "lg");
            compare(item.action, menu.actionAt(0)); compare(item.text, "Action");
            open(menu); mouseClick(item);
            compare(menu.triggers, 1); compare(menu.actionAt(0).checked, true);
            compare(item.checked, true); tryCompare(menu, "visible", false);
            fixture.forceActiveFocus(); keyClick(Qt.Key_K, Qt.ControlModifier);
            compare(menu.triggers, 2); compare(menu.actionAt(0).checked, false);
            menu.actionAt(0).enabled = false;
            compare(item.enabled, false);
        }
        function test_checksAndExclusiveRadio() {
            const menu = make(checksFactory);
            open(menu); mouseClick(menu.itemAt(0)); compare(menu.itemAt(0).checked, true);
            open(menu); mouseClick(menu.itemAt(2));
            compare(menu.itemAt(2).checked, true); compare(menu.itemAt(1).checked, false);
            verify(menu.itemAt(2).radioIndicator);
            menu.itemAt(0).partiallyChecked = true; menu.itemAt(0).checked = false;
            compare(menu.itemAt(0).checked, false);
            open(menu); verify(findChild(menu.itemAt(0), "menuCheckIndicator").visible);
            menu.close();
        }
        function test_nativeSubmenuKeyboard_data() { return [{tag:"LTR", rtl:false}, {tag:"RTL", rtl:true}]; }
        function test_nativeSubmenuKeyboard(data) {
            const menu = make(submenuFactory);
            menu.rightToLeft = data.rtl;
            const openKey = data.rtl ? Qt.Key_Left : Qt.Key_Right;
            const backKey = data.rtl ? Qt.Key_Right : Qt.Key_Left;
            const child = menu.menuAt(1);
            open(menu);
            const opener = menu.itemAt(1);
            compare(opener.subMenu, child); verify(opener.hasSubmenu);
            opener.forceActiveFocus(Qt.TabFocusReason);
            keyClick(openKey); tryCompare(child, "opened", true);
            keyClick(backKey); tryCompare(child, "visible", false);
            opener.forceActiveFocus(Qt.TabFocusReason);
            keyClick(openKey); tryCompare(child, "opened", true);
            child.itemAt(0).forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Return); compare(menu.triggers, 1);
            tryCompare(menu, "visible", false); tryCompare(child, "visible", false);
        }
        function test_iconsHintsMirroringAndScaling() {
            const item = make(itemFactory);
            item.icon.source = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16'%3E%3Crect width='16' height='16' fill='white'/%3E%3C/svg%3E";
            item.shortcutText = "Ctrl+K";
            item.hasSubmenu = true;
            const icon = findChild(item, "menuIcon");
            const label = findChild(item, "menuLabel");
            const hint = findChild(item, "menuShortcut");
            const arrow = findChild(item, "menuSubmenuArrow");
            tryVerify(() => icon.visible && icon.width > 0);
            verify(icon.x < label.x); verify(hint.x > label.x); verify(arrow.x > item.width / 2);
            item.LayoutMirroring.enabled = true;
            verify(item.mirrored); compare(label.effectiveHorizontalAlignment, Text.AlignRight); verify(icon.x > label.x); verify(hint.x < label.x); verify(arrow.x < item.width / 2);
            item.variant = "destructive";
            compare(item.foregroundColor, item.theme.destructive);
            item.highlighted = true;
            compare(item.background.color, item.theme.destructive);
            compare(item.foregroundColor, item.theme.destructiveForeground);
            item.theme.fontScale = 3;
            verify(item.height >= item.contentItem.implicitHeight + item.topPadding + item.bottomPadding);
            item.display = Controls.AbstractButton.TextOnly; compare(icon.visible, false);
            item.display = Controls.AbstractButton.IconOnly; compare(label.visible, false);
        }
        function test_popupThemeAndIntrinsicSize() {
            const menu = make(actionFactory);
            menu.theme.popup = "#123456"; menu.theme.popupForeground = "#abcdef";
            compare(menu.background.color, "#123456");
            compare(menu.itemAt(0).foregroundColor, "#abcdef");
            menu.actionAt(0).text = "A much longer menu action with a readable complete title";
            open(menu);
            tryVerify(() => menu.width >= menu.itemAt(0).implicitWidth);
            menu.theme.fontScale = 2;
            tryVerify(() => menu.itemAt(0).height >= menu.itemAt(0).contentItem.implicitHeight + menu.itemAt(0).topPadding + menu.itemAt(0).bottomPadding);
            menu.close();
        }
    }
}
