import QtQuick
import QtTest
import "../app" as App
import "../stories" as Stories

Item {
    id: host
    width: 1320; height: 840
    Stories.Catalog { id: stories }
    Component { id: factory; App.Explorer { width: host.width; height: host.height; catalog: stories.entries } }
    TestCase {
        name: "SavedSessions"
        when: windowShown
        function init() { failOnWarning(/.*/); }
        function test_savedDesignsAndSession() {
            const explorer = createTemporaryObject(factory, host);
            const builder = explorer.presetBuilder;
            const store = explorer.sessionState;
            builder.createState.setOption("accent", "ocean");
            builder.createState.toggleLock("radius");
            builder.omarchyPreview = true; builder.radiusMultiplier = 0.75; builder.followTypography = false; builder.dark = false;
            const original = JSON.stringify(builder.designSnapshot());
            verify(store.saveDesign("Ocean"));
            compare(store.saveDesign("ocean"), false); compare(store.designs.length, 1);
            builder.createState.setOption("accent", "rose"); builder.omarchyPreview = false;
            verify(store.saveDesign("Rose"));
            verify(store.loadDesign(0)); compare(JSON.stringify(builder.designSnapshot()), original);
            compare(store.renameDesign(0, "Rose"), false);
            verify(store.renameDesign(0, "New ocean")); compare(store.designs[0].name, "New ocean");
            verify(store.deleteDesign(1)); compare(store.designs.length, 1);
            explorer.createMode = true; explorer.explorerState.grid = false; explorer.explorerState.viewportWidth = 640;
            explorer.explorerState.logEvent("private", "not saved");
            const data = JSON.parse(store.snapshot);
            verify(!JSON.stringify(data).includes("private")); verify(!JSON.stringify(data).includes('"args"'));
            const other = createTemporaryObject(factory, host); other.sessionState.restore(data);
            compare(JSON.stringify(other.presetBuilder.designSnapshot()), original);
            compare(other.createMode, true); compare(other.explorerState.viewportWidth, 640); compare(other.explorerState.grid, false);
            compare(other.sessionState.designs[0].name, "New ocean");
            compare(other.explorerState.events.length, 0);
        }
        function test_snapshotTracksBindings() {
            const explorer = createTemporaryObject(factory, host);
            const before = explorer.sessionState.snapshot;
            explorer.presetBuilder.followSpacing = false;
            verify(explorer.sessionState.snapshot !== before);
            const next = explorer.sessionState.snapshot;
            explorer.createState.toggleLock("radius"); verify(explorer.sessionState.snapshot !== next);
        }
    }
}
