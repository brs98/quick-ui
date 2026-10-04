import QtQuick
import QtTest
import "../integrations/omarchy-audio/Actions.js" as Actions
import "../integrations/omarchy-audio/Model.js" as Model

TestCase {
    name: "QuickUIAudioAdapter"
    function test_volumeBoundsAndUnavailable() {
        const physical = {audio: {volume: 0.6, muted: false}};
        compare(Actions.setVolume(physical, 3, 1), 1);
        compare(physical.audio.volume, 1);
        compare(Actions.setVolume(physical, -1, 1), 0);
        compare(Actions.setVolume(physical, 3, 1.5), 1.5);
        compare(Actions.setVolume(physical, NaN, 1), 1.5);
        compare(Actions.setVolume(null, 1, 1), 0);
        compare(Actions.setVolume({}, 1, 1), 0);
    }
    function test_masterMuteAndMissingChannel() {
        const output = {audio: {muted: false}};
        const input = {audio: {muted: true}};
        Actions.toggleAll(output, input);
        verify(output.audio.muted && input.audio.muted);
        Actions.toggleAll(output, input);
        verify(!output.audio.muted && !input.audio.muted);
        Actions.toggleAll(output, null);
        verify(output.audio.muted);
        Actions.toggleAll(output, null);
        verify(!output.audio.muted);
        Actions.toggleMute(input);
        verify(input.audio.muted);
        Actions.toggleMute(null);
        Actions.toggleAll(null, null);
    }
    function test_deviceSelectionAndStaleId() {
        const output = {id: 3, name: "speakers"};
        const input = {id: 4, name: "mic"};
        const service = {};
        const commands = [];
        const execute = command => commands.push(command);
        Actions.selectDevice(output, true, service, execute);
        compare(service.preferredDefaultAudioSink, output);
        compare(JSON.stringify(commands[0]), JSON.stringify(["omarchy-audio-output-set-default", "3", "speakers"]));
        Actions.selectDevice(input, false, service, execute);
        compare(service.preferredDefaultAudioSource, input);
        compare(commands[1][0], "omarchy-audio-input-set-default");
        compare(Actions.nodeWithId([null, output, null, input], "4"), input);
        compare(Actions.nodeWithId([output], "4"), null);
        Actions.selectDevice(null, false, service, execute);
        compare(commands.length, 2);
    }
    function test_playbackClassificationAndSafeProperties() {
        verify(Model.isPlaybackStream({isStream: true, isSink: true}));
        verify(Model.isPlaybackStream({isStream: true, type: "Stream/Output/Audio"}));
        verify(!Model.isPlaybackStream({isStream: true, isSink: false, type: "Stream/Input/Audio"}));
        verify(!Model.isPlaybackStream({isStream: false, isSink: true}));
        const unbound = {ready: false, get properties() { fail("Unbound node properties were accessed"); return {}; }};
        compare(Object.keys(Model.nodeProps(unbound)).length, 0);
        const original = [{id: 1}];
        const snapshot = Model.listSnapshot(original);
        original.push({id: 2});
        compare(snapshot.length, 1);
        const available = Model.parseSinkAvailability("speakers\t1\nhdmi\t0\n");
        compare(available.speakers, true);
        compare(available.hdmi, false);
    }
    function test_labelsAndMprisMatching() {
        compare(Model.nodeLabel({nickname: "Built-in Audio Speakers Output"}), "Speakers");
        compare(Model.friendlyStreamLabel("spotify"), "Spotify");
        const player = {identity: "Spotify", canPlay: true, isPlaying: true};
        const generic = {name: "audio-src"};
        compare(Model.streamLabel(generic, [player], [generic]), "Spotify");
        verify(Model.streamRepresentsPlayer(generic, player, [player], [generic]));
        compare(Model.outputVolumeName(0.6, true), "Muted");
    }
}
