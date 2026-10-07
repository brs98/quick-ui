import QtQuick
import QtTest
import "../app" as App

Item {
    id: host
    width: 1320; height: 1000
    Component { id: factory; App.PresetBuilder { width: host.width; height: host.height } }
    TestCase {
        name: "OmarchyPreview"
        when: windowShown
        function init() { failOnWarning(/.*/); host.width = 1320; }
        function make() {
            const builder = createTemporaryObject(factory, host);
            verify(builder);
            return builder;
        }
        function test_optInAndLiveTokens() {
            const builder = make();
            const code = builder.createState.code;
            const fallback = builder.generatedTheme.accent.toString();
            builder.hostTokens = {accent: "#22bb66", radius: 10, radiusSmall: 6, radiusLarge: 14,
                fontFamily: "monospace", fontSize: 19, controlHeight: 48, dark: false};
            builder.hostAvailable = true;
            compare(builder.omarchyPreview, false);
            compare(builder.effectiveTheme.accent.toString(), fallback);
            builder.omarchyPreview = true;
            compare(builder.effectiveTheme.accent.toString(), "#22bb66");
            compare(builder.effectiveTheme.fontSize, 19);
            compare(builder.effectiveTheme.controlHeight, 48);
            compare(builder.effectiveTheme.dark, false);
            builder.radiusMultiplier = 0.5;
            compare(builder.effectiveTheme.radius, 5);
            compare(builder.effectiveTheme.radiusSmall, 3);
            builder.hostTokens = Object.assign({}, builder.hostTokens, {radius: 0, radiusSmall: 0, radiusLarge: 0, accent: "#bb2266"});
            compare(builder.effectiveTheme.radius, 0);
            compare(builder.effectiveTheme.accent.toString(), "#bb2266");
            compare(builder.createState.code, code, "Host changes must not alter the portable code");
            builder.hostAvailable = false;
            compare(builder.effectiveTheme.accent.toString(), fallback);
        }
        function test_overridesAndRecipeRoundTrip() {
            const builder = make();
            builder.hostTokens = {radius: 20, fontSize: 22, controlHeight: 60, motionDuration: 999};
            builder.hostAvailable = true;
            builder.omarchyPreview = true;
            builder.followRadius = false;
            builder.followTypography = false;
            builder.followSpacing = false;
            builder.createState.setOption("density", "compact");
            builder.createState.setOption("motion", "none");
            compare(builder.effectiveTheme.radius, builder.generatedTheme.radius);
            compare(builder.effectiveTheme.fontSize, builder.generatedTheme.fontSize);
            compare(builder.effectiveTheme.controlHeight, builder.generatedTheme.controlHeight);
            compare(builder.effectiveTheme.motionDuration, 0);
            builder.radiusMultiplier = 1.25;
            const recipe = builder.exportRecipe();
            const restored = make();
            verify(restored.loadDesign(recipe));
            compare(restored.omarchyPreview, true);
            compare(restored.exportRecipe(), recipe);
            compare(restored.createState.code, builder.createState.code);
            const invalid = JSON.parse(recipe);
            invalid.radiusMultiplier = 3;
            verify(!restored.loadDesign(JSON.stringify(invalid)));
            compare(restored.exportRecipe(), recipe);
            invalid.radiusMultiplier = 1;
            invalid.preset = "q2-invalid";
            verify(!restored.loadDesign(JSON.stringify(invalid)));
            compare(restored.exportRecipe(), recipe);
            verify(restored.createState.error.length > 0);
        }
        function test_narrowControls() {
            host.width = 640;
            const builder = make();
            const toggle = findChild(builder, "omarchyPreviewToggle");
            verify(waitForRendering(toggle));
            toggle.forceActiveFocus(); keyClick(Qt.Key_Space);
            verify(builder.omarchyPreview);
            const radius = findChild(builder, "hostRadiusMultiplier");
            radius.forceActiveFocus(); keyClick(Qt.Key_Right);
            compare(builder.radiusMultiplier, 1.25);
            const follow = findChild(builder, "followTypography");
            follow.forceActiveFocus(); keyClick(Qt.Key_Space);
            compare(builder.followTypography, false);
            verify(waitForRendering(builder));
            verify(radius.mapToItem(builder, radius.width, 0).x <= builder.width);
        }
    }
}
