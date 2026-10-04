import QtQuick
import QtQuick.Controls.Basic as Controls
import QtTest
import "../registry/quickui" as UI
import "../stories/primitives" as Stories

Item {
    id: scene
    width: 720
    height: 600
    Component { id: buttonFactory; UI.Button { text: "<b>Save</b>"; x: 20; y: 20 } }
    Component { id: iconButtonFactory; UI.IconButton { text: "+"; accessibleLabel: "Add workspace" } }
    Component { id: badgeFactory; UI.Badge { text: "Very long connection status" } }
    Component { id: separatorFactory; UI.Separator {} }
    Component { id: buttonStoryFactory; Stories.ButtonStory {} }
    Component { id: iconStoryFactory; Stories.IconButtonStory {} }
    Component { id: badgeStoryFactory; Stories.BadgeStory {} }
    Component { id: cardStoryFactory; Stories.CardStory {} }
    Component { id: separatorStoryFactory; Stories.SeparatorStory {} }
    SignalSpy { id: spy }

    TestCase {
        name: "QuickUIPresentationHardening"
        when: windowShown
        function init() { failOnWarning(/.*/); spy.clear(); }
        function cleanup() { spy.target = null; }
        function make(factory, properties) {
            const item = createTemporaryObject(factory, parent, properties || {});
            verify(item !== null);
            return item;
        }
        function child(item, predicate) {
            for (const current of item.children) {
                if (predicate(current)) return current;
                const nested = child(current, predicate);
                if (nested) return nested;
            }
            return null;
        }
        function graphic(button) { return child(button.contentItem, item => item.icon !== undefined); }
        function label(button) { return child(button.contentItem, item => item.textFormat !== undefined && item.text === button.text); }
        function checkCenterColor(item, expected) {
            wait(30);
            const shot = grabImage(scene);
            const center = item.mapToItem(scene, item.width / 2, item.height / 2);
            compare(shot.pixel(Math.floor(center.x), Math.floor(center.y)), expected);
        }

        function test_sourceIconTintSizeAndThemeFallback() {
            const button = make(buttonFactory);
            button.display = Controls.Button.IconOnly;
            button.icon.source = Qt.resolvedUrl("fixtures/presentation-icon.svg");
            button.icon.width = 24;
            button.icon.height = 24;
            button.icon.color = "transparent";
            const image = graphic(button);
            tryCompare(image, "implicitWidth", 24);
            compare(image.implicitHeight, 24);
            checkCenterColor(image, "#ff0000");
            button.icon.name = "quickui-definitely-nonexistent-icon-name";
            checkCenterColor(image, "#ff0000");
            button.icon.color = "#00ff00";
            checkCenterColor(image, "#00ff00");
            button.icon.width = 32;
            button.icon.height = 32;
            tryCompare(image, "implicitWidth", 32);
            compare(image.implicitHeight, 32);
            compare(image.enabled, false);
            compare(image.focusPolicy, Qt.NoFocus);
            compare(image.Accessible.ignored, true);
            spy.target = button; spy.signalName = "clicked";
            mouseClick(image, image.width / 2, image.height / 2);
            compare(spy.count, 1, "Decorative icon must not intercept activation");
        }

        function test_displayPlainTextAndMirroring() {
            const button = make(buttonFactory);
            button.icon.source = Qt.resolvedUrl("fixtures/presentation-icon.svg");
            const image = graphic(button), text = label(button);
            compare(text.textFormat, Text.PlainText);
            compare(text.text, "<b>Save</b>");
            verify(image.visible && text.visible);
            verify(image.x < text.x);
            button.iconPosition = "trailing";
            verify(image.x > text.x);
            button.LayoutMirroring.enabled = true;
            verify(image.x < text.x);
            button.iconPosition = "leading";
            verify(image.x > text.x);
            button.display = Controls.Button.TextUnderIcon;
            verify(image.y < text.y);
            verify(button.implicitHeight >= image.height + text.height + button.spacing);
            button.display = Controls.Button.TextOnly;
            verify(!image.visible && text.visible);
            button.display = Controls.Button.IconOnly;
            verify(image.visible && !text.visible);
            compare(button.Accessible.name, button.text);
        }

        function test_sizesOutlineAndGlyphFallback() {
            const button = make(buttonFactory, {text: "Save", variant: "outline"});
            const icon = make(iconButtonFactory);
            for (const size of ["sm", "default", "lg"]) {
                button.size = size; icon.size = size;
                compare(button.height, button.theme.heightFor(size));
                compare(icon.height, icon.theme.heightFor(size));
                compare(icon.width, icon.height);
                compare(button.padding, button.theme.paddingFor(size));
            }
            compare(button.background.border.width, button.theme.borderWidth);
            compare(button.background.color, "#00000000");
            compare(icon.contentItem.text, "+");
            compare(icon.Accessible.name, "Add workspace");
            icon.icon.source = Qt.resolvedUrl("fixtures/presentation-icon.svg");
            compare(icon.display, Controls.Button.IconOnly);
            verify(!label(icon).visible);
            compare(icon.Accessible.name, "Add workspace");
            spy.target = icon; spy.signalName = "clicked";
            icon.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Space);
            compare(spy.count, 1);
            icon.enabled = false;
            keyClick(Qt.Key_Space);
            compare(spy.count, 1);
            button.theme.fontScale = 2;
            verify(button.height >= label(button).implicitHeight + button.topPadding + button.bottomPadding);
        }

        function test_loadingOwnerPolicyAndStableDimensions() {
            const story = make(buttonStoryFactory, {args: {iconKind: "source"}});
            const button = child(story, item => item.loading !== undefined);
            spy.target = story; spy.signalName = "eventRaised";
            button.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Space);
            compare(spy.count, 1);
            const width = button.width, height = button.height;
            story.args = {iconKind: "source", loading: true};
            compare(button.width, width);
            compare(button.height, height);
            compare(button.Accessible.description, "Loading");
            compare(button.enabled, true);
            compare(button.activeFocus, true);
            mouseClick(button, button.width / 2, button.height / 2);
            keyClick(Qt.Key_Space);
            compare(spy.count, 1);
            button.theme.motionDuration = 0;
            story.args = {iconKind: "source", loading: false};
            compare(button.activeFocus, true);
            keyClick(Qt.Key_Space);
            compare(spy.count, 2);
        }

        function test_badgeDecorationsElisionAndMirroring() {
            const badge = make(badgeFactory, {variant: "outline", width: 100});
            compare(badge.elide, Text.ElideRight);
            compare(badge.maximumLineCount, 1);
            verify(badge.truncated);
            compare(badge.background.color, "#00000000");
            compare(badge.background.border.width, badge.theme.borderWidth);
            badge.statusDot = true;
            verify(badge.leftPadding > badge.rightPadding);
            badge.LayoutMirroring.enabled = true;
            verify(badge.rightPadding > badge.leftPadding);
            badge.statusDot = false;
            badge.icon.source = Qt.resolvedUrl("fixtures/presentation-icon.svg");
            badge.icon.width = 24; badge.icon.height = 24;
            verify(badge.height >= 24 + 6);
            compare(badge.height, badge.contentHeight + badge.topPadding + badge.bottomPadding);
            const image = child(badge, item => item.icon !== undefined);
            compare(image.Accessible.ignored, true);
            compare(image.focusPolicy, Qt.NoFocus);
            badge.busy = true;
            verify(!image.visible);
            compare(badge.Accessible.name, badge.text);
            compare(badge.activeFocusOnTab, false);
        }

        function test_cardSingleLayoutWrapAndCompact() {
            const story = make(cardStoryFactory, {width: 260, args: {description: "A longer description wraps naturally inside the one layout that owns the header, content and footer."}});
            const card = child(story, item => item.contentChildren !== undefined && item.size !== undefined);
            compare(card.contentChildren.length, 1);
            const content = card.contentChildren[0];
            compare(content.width, card.availableWidth);
            compare(card.implicitHeight, content.implicitHeight + card.topPadding + card.bottomPadding);
            const oldHeight = card.implicitHeight;
            story.width = 190;
            tryVerify(() => card.implicitHeight > oldHeight);
            story.args = {size: "sm"};
            compare(card.padding, card.theme.paddingFor("sm"));
            card.theme.card = "#123456";
            compare(card.background.color, "#123456");
            const action = child(card, item => item.text === "Continue");
            spy.target = story; spy.signalName = "eventRaised";
            mouseClick(action, action.width / 2, action.height / 2);
            compare(spy.count, 1);
        }

        function test_separatorSemantics() {
            const separator = make(separatorFactory);
            compare(separator.Accessible.ignored, true);
            separator.semantic = true;
            compare(separator.Accessible.ignored, false);
            compare(separator.Accessible.role, Accessible.Separator);
            separator.vertical = true;
            compare(separator.width, separator.theme.borderWidth);
            compare(separator.height, 100);
        }

        function test_storyModes_data() {
            const result = [];
            for (const dark of [true, false]) {
                for (const size of ["sm", "default", "lg"]) {
                    result.push({tag: dark + "-" + size, dark: dark, size: size});
                }
            }
            return result;
        }
        function test_storyModes(data) {
            for (const factory of [buttonStoryFactory, iconStoryFactory, badgeStoryFactory, cardStoryFactory, separatorStoryFactory]) {
                const story = make(factory, {dark: data.dark, args: {size: data.size, iconKind: "theme", decoration: "busy", semantic: true}});
                verify(story.implicitWidth > 0 && story.implicitHeight > 0);
                story.width = Math.min(story.implicitWidth, 220);
                verify(waitForRendering(story));
                verify(grabImage(story).width > 0);
            }
        }
    }
}
