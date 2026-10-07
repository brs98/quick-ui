import QtQuick
import QtTest
import "../app" as App
import "../app/PresetCodec.js" as Codec
import "../registry/quickui" as UI

Item {
    id: host
    width: 1320; height: 840
    Component { id: stateFactory; App.PresetState {} }
    Component { id: builderFactory; App.PresetBuilder { width: host.width; height: host.height } }
    UI.Theme { id: hostTheme; accent: "#125678"; selection: "#abcdef"; fontFamily: "monospace"; radius: 2 }
    Component { id: themeFactory; App.PresetTheme {} }
    TestCase {
        name: "PresetEditor"
        when: windowShown
        function init() { failOnWarning(/.*/); host.width = 1320; host.height = 840; }
        function option(state, key) { return state.options.find(row => row.key === key); }
        function test_locksAndShuffle() {
            const state = createTemporaryObject(stateFactory, host);
            verify(state);
            const initial = JSON.stringify(state.config);
            state.toggleLock("accent");
            const accent = state.config.accent;
            verify(state.shuffle());
            compare(state.config.accent, accent);
            verify(JSON.stringify(state.config) !== initial);
            compare(Codec.encode(Codec.decode(state.code)), state.code);
            verify(state.undo()); compare(JSON.stringify(state.config), initial);
            for (const row of state.options) if (!state.locks[row.key]) state.toggleLock(row.key);
            const length = state.history.length;
            compare(state.shuffle(), false); compare(state.history.length, length);
            compare(state.toggleLock("bogus"), false);
        }
        function test_validationUndoAndExport() {
            const state = createTemporaryObject(stateFactory, host);
            const initial = state.code;
            verify(state.setOption("accent", option(state, "accent").values[1].value));
            const edited = state.code;
            verify(edited !== initial);
            compare(state.loadCode("q9-not-a-code"), false);
            compare(state.code, edited); verify(state.error.length > 0);
            compare(state.history.length, 1);
            compare(state.setOption("bogus", "value"), false); compare(state.code, edited);
            verify(state.loadCode(initial)); compare(state.code, initial); compare(state.error, "");
            verify(state.undo()); compare(state.code, edited);
            const saved = JSON.parse(state.exportJson());
            compare(saved.schemaVersion, 1); compare(saved.code, edited);
            compare(JSON.stringify(saved.config), JSON.stringify(state.config));
            verify(state.reset()); compare(state.code, initial);
            verify(state.undo()); compare(state.code, edited);
            for (let index = 0; index < 80; ++index)
                state.setOption("accent", option(state, "accent").values[index % 2].value);
            compare(state.history.length, state.historyLimit);
        }
        function test_themePropagationAndHostColors() {
            const state = createTemporaryObject(stateFactory, host);
            const theme = createTemporaryObject(themeFactory, host, {config: state.config});
            verify(theme);
            const original = theme.background.toString();
            theme.dark = false; verify(theme.background.toString() !== original);
            state.setOption("radius", option(state, "radius").values[0].value);
            state.setOption("font", "serif"); state.setOption("colorSource", "system");
            theme.config = state.config;
            compare(theme.followsHost, false);
            compare(theme.radius, Codec.resolve(state.config, false).radius);
            theme.systemTheme = hostTheme;
            compare(theme.followsHost, true); compare(theme.accent, hostTheme.accent);
            compare(theme.selection, hostTheme.selection);
            compare(theme.fontFamily, Codec.resolve(state.config, false).fontFamily);
            hostTheme.accent = "#654321"; compare(theme.accent, hostTheme.accent);
            state.setOption("colorSource", "preset"); theme.config = state.config;
            compare(theme.followsHost, false);
            compare(theme.accent.toString(), Codec.resolve(state.config, false).accent);
        }
        function test_keyboardControlsAndUndoBindings() {
            const builder = createTemporaryObject(builderFactory, host); verify(builder);
            const select = findChild(builder, "presetOption-palette"); verify(select);
            const state = builder.createState;
            const initial = state.config.palette;
            select.forceActiveFocus(Qt.TabFocusReason); keyClick(Qt.Key_Down);
            verify(state.config.palette !== initial);
            verify(state.undo()); compare(state.config.palette, initial); compare(select.currentIndex, 0);
            const lock = findChild(builder, "presetLock-palette"); verify(lock);
            lock.forceActiveFocus(Qt.TabFocusReason); keyClick(Qt.Key_Space);
            compare(state.locks.palette, true); compare(lock.checked, true);
            state.shuffle(); compare(state.config.palette, initial); compare(lock.checked, true);
            keyClick(Qt.Key_Space); compare(state.locks.palette, false);
            const entry = findChild(builder, "presetLoadCode"); verify(entry);
            const saved = state.code;
            entry.text = "invalid"; entry.forceActiveFocus(); keyClick(Qt.Key_Return);
            compare(state.code, saved); verify(state.error.length > 0);
            entry.text = Codec.encode(Codec.defaults()); keyClick(Qt.Key_Return);
            compare(state.error, ""); compare(state.code, entry.text);
            compare(builder.generatedTheme.config, state.config);
        }
        function test_compactGeometry() {
            host.width = 640; host.height = 700;
            const builder = createTemporaryObject(builderFactory, host); verify(builder); wait(0);
            compare(builder.compact, true);
            const gallery = findChild(builder, "presetGallery"); verify(gallery);
            verify(gallery.width > 300); verify(gallery.width <= host.width - 32);
            const select = findChild(builder, "presetOption-colorSource"); verify(select);
            verify(select.width > 100);
            verify(select.mapToItem(builder, select.width, 0).x <= builder.width);
            const code = findChild(builder, "presetGeneratedCode"); verify(code); verify(code.width > 100);
        }
    }
}
