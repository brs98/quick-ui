import QtQuick
import QtTest
import "../registry/quickui" as UI

Item {
    width: 640
    height: 600
    Component { id: themeFactory; UI.Theme {} }
    Component { id: modelFactory; ListModel {} }
    Component { id: sliderFactory; UI.Slider { x: 20; y: 20; from: 0; to: 100; value: 50; stepSize: 5 } }
    Component { id: selectFactory; UI.Select { x: 20; y: 80; model: ["One", "Two", "Three"] } }
    Component { id: badgeFactory; UI.Badge { text: "Ready" } }
    Component { id: separatorFactory; UI.Separator {} }
    Component {
        id: cardFactory
        UI.Card {
            Column {
                spacing: 8
                UI.Badge { text: "Status" }
                Rectangle { width: 180; height: 60; color: "red" }
            }
        }
    }
    SignalSpy { id: spy }

    TestCase {
        name: "QuickUISurfaces"
        when: windowShown

        function init() { failOnWarning(/.*/); spy.clear(); }
        function cleanup() { spy.target = null; }
        function make(factory, properties) {
            const item = createTemporaryObject(factory, parent, properties || {});
            verify(item !== null);
            return item;
        }
        function click(item) { mouseClick(item, item.width / 2, item.height / 2); }

        function test_sliderKeyboardAndDisabled() {
            const slider = make(sliderFactory);
            spy.signalName = "moved";
            spy.target = slider;
            slider.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Right);
            compare(slider.value, 55);
            compare(spy.count, 1);
            keyClick(Qt.Key_Left);
            compare(slider.value, 50);
            slider.enabled = false;
            keyClick(Qt.Key_Right);
            compare(slider.value, 50);
            compare(spy.count, 2);
        }

        function test_sliderMouseAndOrientation() {
            const slider = make(sliderFactory);
            spy.signalName = "moved";
            spy.target = slider;
            mouseClick(slider, slider.width - slider.rightPadding - 2, slider.height / 2);
            verify(slider.value > 90);
            verify(spy.count > 0);
            slider.orientation = Qt.Vertical;
            slider.value = 50;
            slider.forceActiveFocus();
            keyClick(Qt.Key_Up);
            compare(slider.value, 55);
            verify(slider.handle.y < slider.height / 2);
        }

        function test_selectKeyboardSignalsAndRoles() {
            const select = make(selectFactory, {
                model: [{ label: "Alpha", key: 1 }, { label: "Beta", key: 2 }, { label: "Gamma", key: 3 }],
                textRole: "label", valueRole: "key"
            });
            spy.signalName = "activated";
            spy.target = select;
            select.forceActiveFocus();
            keyClick(Qt.Key_Down);
            compare(select.currentIndex, 1);
            compare(select.currentText, "Beta");
            compare(select.currentValue, 2);
            compare(spy.count, 1);
            select.currentIndex = 0;
            compare(spy.count, 1, "Programmatic changes must not emit user activation");
            keyClick(Qt.Key_Space);
            tryCompare(select.popup, "visible", true);
            keyClick(Qt.Key_Down);
            keyClick(Qt.Key_Return);
            tryCompare(select.popup, "visible", false);
            compare(select.currentIndex, 1);
            compare(spy.count, 2);
        }

        function test_selectPopupMouseAndDisabled() {
            const select = make(selectFactory);
            spy.signalName = "activated";
            spy.target = select;
            click(select);
            tryCompare(select.popup, "visible", true);
            const list = select.popup.contentItem;
            tryVerify(() => list.itemAtIndex(2) !== null);
            verify(waitForRendering(list));
            const option = list.itemAtIndex(2);
            click(option);
            tryCompare(select.popup, "visible", false);
            compare(select.currentIndex, 2);
            compare(spy.count, 1);
            select.enabled = false;
            click(select);
            compare(select.popup.visible, false);
            compare(spy.count, 1);
        }

        function test_selectLiveModelEdits() {
            const select = make(selectFactory);
            const model = make(modelFactory);
            model.append({label: "Before"});
            select.textRole = "label";
            select.model = model;
            click(select);
            tryCompare(select.popup, "visible", true);
            const list = select.popup.contentItem;
            tryVerify(() => list.itemAtIndex(0) !== null);
            compare(list.itemAtIndex(0).text, "Before");
            model.setProperty(0, "label", "After");
            compare(list.itemAtIndex(0).text, "After");
            compare(select.currentText, "After");
            select.popup.close();
        }

        function test_selectLongListScrollAndTheme() {
            const entries = [];
            for (let i = 0; i < 40; ++i) entries.push("Entry " + i);
            const select = make(selectFactory, {model: entries});
            const theme = make(themeFactory, {dark: false, surface: "#123456", accent: "#abcdef"});
            select.theme = theme;
            click(select);
            tryCompare(select.popup, "visible", true);
            const list = select.popup.contentItem;
            verify(list.contentHeight > list.height);
            compare(select.popup.background.color, theme.surface);
            select.forceActiveFocus();
            for (let i = 0; i < 30; ++i) keyClick(Qt.Key_Down);
            compare(select.highlightedIndex, 30);
            tryVerify(() => list.contentY > 0);
            tryVerify(() => list.itemAtIndex(30) !== null);
            const option = list.itemAtIndex(30);
            compare(option.background.color, theme.accent);
            compare(option.contentItem.color, theme.accentForeground);
            theme.accent = "#fedcba";
            compare(option.background.color, theme.accent);
            keyClick(Qt.Key_Return);
            compare(select.currentIndex, 30);
        }

        function test_cardDefaultContentComposition() {
            const card = make(cardFactory);
            compare(card.contentChildren.length, 1);
            const content = card.contentChildren[0];
            compare(content.parent, card.contentItem);
            verify(card.implicitWidth >= 180 + card.leftPadding + card.rightPadding);
            verify(card.implicitHeight >= content.implicitHeight + card.topPadding + card.bottomPadding);
            card.theme.padding = 24;
            compare(card.padding, 24);
            compare(card.implicitWidth, 228);
        }

        function test_themeUpdates_data() { return [{tag: "dark", dark: true}, {tag: "light", dark: false}]; }
        function test_themeUpdates(data) {
            const card = make(cardFactory);
            const badge = make(badgeFactory);
            const separator = make(separatorFactory);
            const slider = make(sliderFactory);
            const select = make(selectFactory);
            // QtTest destroys temporary objects in creation order; shared dependencies outlive consumers.
            const theme = make(themeFactory, {dark: data.dark});
            for (const control of [card, badge, separator, slider, select]) control.theme = theme;
            compare(card.background.color, theme.surface);
            compare(badge.background.color, theme.surfaceHover);
            compare(separator.color, theme.border);
            compare(slider.handle.border.color, theme.accent);
            compare(select.palette.text, theme.foreground);
            theme.dark = !theme.dark;
            compare(card.background.color, theme.surface);
            compare(select.palette.text, theme.foreground);
            theme.surface = "#223344";
            theme.border = "#445566";
            theme.accent = "#667788";
            theme.accentForeground = "#112233";
            compare(card.background.color, "#223344");
            compare(separator.color, "#445566");
            compare(slider.handle.border.color, "#667788");
            badge.variant = "accent";
            compare(badge.background.color, "#667788");
            compare(badge.color, "#112233");
            badge.variant = "destructive";
            compare(badge.background.color, theme.destructive);
            compare(badge.color, theme.destructiveForeground);
            separator.vertical = true;
            compare(separator.implicitWidth, theme.borderWidth);
            compare(separator.implicitHeight, 100);
            separator.vertical = false;
            compare(separator.implicitHeight, theme.borderWidth);
        }
    }
}
