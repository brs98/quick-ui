import QtQuick
import QtTest
import "../registry/quickui" as UI
import "../integrations/omarchy-theme" as Omarchy
import "../integrations/omarchy-theme/OmarchyTokens.js" as Mapper

Item {
    UI.Theme { id: preset; radius: 7; radiusSmall: 3; radiusLarge: 12; motionDuration: 333; density: "comfortable" }
    QtObject {
        id: colors
        property color background: "#101315"
        property color foreground: "#eeeeee"
        property color accent: "#88ccff"
        property color urgent: "#ff6666"
        property color muted: "#888888"
        property QtObject popups: QtObject {
            property color background: "#cc101315"
            property color text: "#ffffff"
            property color border: "#9988ccff"
        }
    }
    QtObject {
        id: style
        property int cornerRadius: 10
        property real fontScale: 1.5
        property color hoverFill: "#14eeeeee"
        property color selectedFill: "#2eeeeeee"
        property color focusBorderColor: "#40eeeeee"
        property int normalBorderWidth: 1
        property int focusBorderWidth: 2
        property QtObject font: QtObject {
            property string resolvedFamily: "monospace"
            property int body: 18
            property int bodySmall: 16
        }
        property QtObject spacing: QtObject {
            property int controlGap: 12
            property int controlPaddingX: 15
            property int controlHeight: 42
        }
        function space(size) { return Math.round(size * fontScale); }
    }
    Omarchy.ShellThemeSource { id: source; colorSource: colors; styleSource: style }
    Component { id: factory; UI.HostTheme { presetTheme: preset; hostTokens: source.tokens } }
    TestCase {
        name: "HostTheme"
        when: windowShown
        function init() {
            failOnWarning(/.*/);
            colors.background = "#101315"; colors.accent = "#88ccff";
            colors.popups.background = "#cc101315";
            style.cornerRadius = 10; style.font.body = 18; style.fontScale = 1.5;
            style.spacing.controlGap = 12;
        }
        function make() { const t = createTemporaryObject(factory, this); verify(t); return t; }
        function test_fallbackCopiesEveryPresetToken() {
            const t = make(); t.hostTokens = null; t.radiusMultiplier = 2;
            const fields = ["dark", "background", "surface", "surfaceHover", "foreground", "mutedForeground", "border", "accent", "accentForeground", "destructive", "destructiveForeground", "focus", "primary", "primaryForeground", "selection", "selectionForeground", "popup", "popupForeground", "card", "cardForeground", "fontFamily", "fontScale", "fontSize", "smallFontSize", "radius", "radiusSmall", "radiusLarge", "spacing", "padding", "controlHeight", "handleSize", "borderWidth", "focusWidth", "density", "motionDuration", "disabledOpacity"];
            fields.forEach(function (key) { compare(t[key], preset[key], key); });
        }
        function test_independentCompositionGroups() {
            const t = make();
            compare(t.fontSize,18); compare(t.radius,10); compare(t.padding,15); compare(t.controlHeight,42); compare(t.handleSize,21);
            compare(t.motionDuration,333); compare(t.density,"comfortable");
            compare(t.background,colors.background); compare(t.primary,colors.accent);
            t.followColors = false; compare(t.background,preset.background); compare(t.fontSize,18);
            t.followTypography = false; compare(t.fontSize,preset.fontSize); compare(t.radius,10);
            t.followRadius = false; compare(t.radius,preset.radius); compare(t.radiusSmall,preset.radiusSmall);
            t.followSpacing = false; compare(t.controlHeight,preset.controlHeight); compare(t.spacing,preset.spacing);
        }
        function test_relativeRadiusAndSharpThemes() {
            const t = make(); t.radiusMultiplier=0.5;
            compare(t.radius,5); compare(t.radiusSmall,3); compare(t.radiusLarge,7);
            t.radiusMultiplier=3; compare(t.radius,20);
            t.radiusMultiplier=-1; compare(t.radius,0);
            t.radiusMultiplier=NaN; compare(t.radius,10);
            style.cornerRadius=0; t.radiusMultiplier=2;
            compare(t.radius,0); compare(t.radiusSmall,0); compare(t.radiusLarge,0);
        }
        function test_liveShellDependenciesAndAlpha() {
            const t = make();
            fuzzyCompare(t.popup.a,0.8,0.005); fuzzyCompare(t.surfaceHover.a,20/255,0.005);
            colors.popups.background="#80ffffff"; colors.background="#ffffff"; colors.accent="#222222";
            style.font.body=24; style.fontScale=2; style.spacing.controlGap=20;
            compare(t.dark,false); compare(t.fontSize,24); compare(t.handleSize,28); compare(t.spacing,20);
            compare(t.accentForeground,"#ffffff"); fuzzyCompare(t.popup.a,128/255,0.005);
        }
        function test_contrastCompositesAlpha() {
            compare(Mapper.contrastForeground("#10ffffff","#000000"),"#ffffff");
            compare(Mapper.contrastForeground("#10000000","#ffffff"),"#000000");
            compare(Mapper.contrastForeground("#777777","#ffffff"),"#000000");
            compare(Mapper.contrastForeground("#000000","#ffffff"),"#ffffff");
        }
        function test_invalidSnapshotAndMissingFields() {
            compare(Mapper.resolve(null),null); compare(Mapper.resolve({}),null);
            compare(Mapper.resolve({colors:{background:"oops",foreground:"#fff"}}),null);
            const tokens=Mapper.resolve({colors:{background:"#fff",foreground:"#111"},style:{radius:-1,fontSize:NaN}});
            compare(tokens.dark,false); compare(tokens.radius,undefined); compare(tokens.fontSize,12);
            const t=make(); t.hostTokens={radius:4}; compare(t.radius,4); compare(t.fontSize,preset.fontSize); compare(t.background,preset.background);
            t.hostTokens={radius:null}; t.radiusMultiplier=2; compare(t.radius,preset.radius);
        }
        function test_unavailableRadiusPreservesPresetGeometry_data() {
            return [{tag:"missing",value:undefined},{tag:"null",value:null},
                    {tag:"negative",value:-1},{tag:"NaN",value:NaN},
                    {tag:"infinite",value:Infinity},{tag:"string",value:"0"}];
        }
        function test_unavailableRadiusPreservesPresetGeometry(data) {
            const tokens=Mapper.resolve({colors:{background:"#111",foreground:"#eee"},style:{radius:data.value}});
            const t=make(); t.hostTokens=tokens; t.radiusMultiplier=2;
            for (const key of ["radius","radiusSmall","radiusLarge"]) {
                verify(!Object.prototype.hasOwnProperty.call(tokens,key),key+" must remain absent");
                compare(t[key],preset[key],key);
            }
            t.hostTokens={radius:data.value};
            compare(t.radius,preset.radius); compare(t.radiusSmall,preset.radiusSmall); compare(t.radiusLarge,preset.radiusLarge);
        }
        function test_explicitZeroRadiusRemainsSquare() {
            const tokens=Mapper.resolve({colors:{background:"#111",foreground:"#eee"},style:{radius:0}});
            const t=make(); t.hostTokens=tokens; t.radiusMultiplier=2;
            for (const key of ["radius","radiusSmall","radiusLarge"]) {
                verify(Object.prototype.hasOwnProperty.call(tokens,key)); compare(tokens[key],0); compare(t[key],0);
            }
        }
        function test_sourceDisconnectFallsBack() {
            const disconnected=createTemporaryObject(Qt.createComponent("../integrations/omarchy-theme/ShellThemeSource.qml"),this);
            verify(disconnected); verify(!disconnected.available); compare(disconnected.tokens,null);
        }
    }
}
