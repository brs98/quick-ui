// SPDX-License-Identifier: MIT
// Copyright (c) David Heinemeier Hansson
// Adapted from Omarchy 4.0.4, shell/plugins/panels/audio/Panel.qml.
// QuickUI integration changes are covered by the project LICENSE.
// Preserve the upstream permission notice in LICENSE.omarchy when redistributing.

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import qs.Ui
import qs.Commons
import "Model.js" as Model
import "Actions.js" as Actions
import "ui" as UI

Panel {
  id: root
  moduleName: "omarchy.audio"
  ipcTarget: "omarchy.audio"

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource
  readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
  readonly property var mprisPlayers: Mpris.players ? Mpris.players.values : []
  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
  readonly property var activeMediaPlayer: mediaService ? mediaService.activePlayer : null

  readonly property var candidateSinks: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && n.isSink && !n.isStream) list.push(n)
    }
    return list
  }

  readonly property var candidateSources: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && !n.isSink && !n.isStream && isAudioSource(n)) {
        var name = n.name || ""
        if (name === "quickshell") continue
        list.push(n)
      }
    }
    return list
  }

  readonly property var candidateStreams: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (!n || !n.isStream || !isPlaybackStream(n)) continue
      // A tuning's output is a playback stream too, but it is the processing
      // itself rather than an application, so it does not belong in the list.
      if (String(n.name || "").indexOf("omarchy_speaker_tuning") === 0) continue
      list.push(n)
    }
    return list
  }

  property var sinkAvailability: ({})
  property bool sinkAvailabilityLoaded: false

  // Identify true playback streams without reading node.properties here:
  // PwNode.properties is invalid until the node is bound, and reading it while
  // capture streams are appearing (for example, when Voxtype starts recording)
  // can destabilize Quickshell's Pipewire service. Quickshell versions differ
  // in how `type` is exposed (media.class, enum name, or numeric enum), but
  // playback streams consistently accept audio input from clients and publish
  // `isSink: true`; capture streams publish as stream sources.
  function isPlaybackStream(node) {
    return Model.isPlaybackStream(node)
  }

  function isAudioSource(node) {
    return Model.isAudioSource(node)
  }

  property var cachedAudioSinks: []
  property var cachedAudioSources: []

  readonly property var rawAudioSinks: {
    var list = []
    for (var i = 0; i < candidateSinks.length; i++)
      if (sinkAvailable(candidateSinks[i])) list.push(candidateSinks[i])
    if (sink && list.indexOf(sink) < 0) list.unshift(sink)
    return list
  }

  readonly property var rawAudioSources: {
    var list = candidateSources.slice()
    if (source && list.indexOf(source) < 0) list.unshift(source)
    return list
  }

  readonly property var audioSinks: rawAudioSinks.length > 0 ? rawAudioSinks : cachedAudioSinks
  readonly property var audioSources: rawAudioSources.length > 0 ? rawAudioSources : cachedAudioSources

  readonly property var audioStreams: {
    var list = []
    for (var i = 0; i < candidateStreams.length; i++)
      if (candidateStreams[i].audio) list.push(candidateStreams[i])
    return list
  }

  // Feed Repeaters with panel-local snapshots instead of the live PipeWire
  // model. PipeWire can remove nodes while Quickshell is dispatching the
  // removal signal; rebuilding a Repeater from that signal path has crashed
  // in Quickshell's PipeWire service. The snapshot timer lets that mutation
  // settle first, and closed panels keep their repeaters detached entirely.
  property var displayAudioSinks: []
  property var displayAudioSources: []
  property var displayAudioStreams: []

  // A DSP sink -- a speaker tuning, or EasyEffects -- can be the selected output
  // without being where loudness lives: changing its volume alters the level going
  // *into* the processing, so the slider would move while the speakers did not,
  // and on a chain with a limiter it would change the tone as well.
  //
  // omarchy-audio-output-sink resolves the *current* default output through any
  // such sink to the physical one, which is the same definition the volume keys
  // and the output switcher use. Resolving the default (rather than "whatever a
  // tuning fronts") is what keeps this correct when headphones or HDMI are
  // selected while a tuning still exists.
  property string volumeSinkName: ""

  // Carry sub-notch touchpad deltas between wheel events.
  property real wheelAccumulator: 0

  readonly property var volumeSink: {
    if (volumeSinkName === "" || !sink) return sink
    if (volumeSinkName === String(sink.name)) return sink
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && n.isSink && !n.isStream && String(n.name) === volumeSinkName && n.audio)
        return n
    }
    return sink
  }

  // Re-resolve whenever the selected output changes; the timer below is only a
  // safety net for the tuning being applied or removed underneath us.
  onSinkChanged: resolveVolumeSink()

  function resolveVolumeSink() {
    if (!volumeSinkProc.running) volumeSinkProc.running = true
  }

  readonly property real outputVolume: volumeSink && volumeSink.audio ? volumeSink.audio.volume : 0
  readonly property bool outputMuted: volumeSink && volumeSink.audio ? volumeSink.audio.muted : false
  readonly property real inputVolume: source && source.audio ? source.audio.volume : 0
  readonly property bool inputMuted: source && source.audio ? source.audio.muted : false

  onRawAudioSinksChanged: if (rawAudioSinks.length > 0) cachedAudioSinks = rawAudioSinks
  onRawAudioSourcesChanged: if (rawAudioSources.length > 0) cachedAudioSources = rawAudioSources

  readonly property bool hasOutput: !!(volumeSink && volumeSink.audio)
  readonly property bool hasInput: !!(source && source.audio)
  readonly property bool anyAudible: (hasOutput && !outputMuted) || (hasInput && !inputMuted)

  onOpenedChanged: {
    if (opened) {
      refreshDisplayAudioModels()
      Qt.callLater(function() { mixer.reset() })
    } else clearDisplayAudioModels()
  }
  onAudioSinksChanged: scheduleDisplayAudioModelRefresh()
  onAudioSourcesChanged: scheduleDisplayAudioModelRefresh()
  onAudioStreamsChanged: scheduleDisplayAudioModelRefresh()

  function refreshDisplayAudioModels() {
    if (!opened) return
    displayAudioSinks = Model.listSnapshot(audioSinks)
    displayAudioSources = Model.listSnapshot(audioSources)
    displayAudioStreams = Model.listSnapshot(audioStreams)
  }
  function scheduleDisplayAudioModelRefresh() {
    if (opened) audioModelRefreshTimer.restart()
  }
  function clearDisplayAudioModels() {
    audioModelRefreshTimer.stop()
    displayAudioSinks = []
    displayAudioSources = []
    displayAudioStreams = []
  }
  function nodeWithId(list, id) { return Actions.nodeWithId(list, id) }
  function setStreamVolume(id, value) {
    Actions.setVolume(nodeWithId(displayAudioStreams, id), value, 1.5)
  }
  function toggleStreamMute(id) {
    Actions.toggleMute(nodeWithId(displayAudioStreams, id))
  }

  function outputIcon(volume) {
    // Match the old Waybar pulseaudio glyph set. The Material Design speaker
    // icons render visually smaller in JetBrainsMono Nerd Font.
    if (!sink || !sink.audio) return ""
    if (isHeadphones(sink)) return "󰋋"
    if (outputMuted) return ""
    var v = volume === undefined ? outputVolume : volume
    if (v >= 0.67) return ""
    if (v >= 0.34) return ""
    if (v > 0) return ""
    return ""
  }


  // Playful mood-name for a given output volume. Mirrors the brightness
  // panel's brightnessName ladder; bands are wide enough that small
  // tweaks don't rename the room you're in.
  function outputVolumeName(volume, muted) {
    return Model.outputVolumeName(volume, muted)
  }

  function setOutputVolume(v) {
    return Actions.setVolume(volumeSink, v, 1)
  }

  function showVolumeOsd(volume) {
    if (!bar || !bar.shell) return
    bar.shell.summon("omarchy.osd", JSON.stringify({
      icon: outputIcon(volume),
      value: Math.round(volume * 100)
    }))
  }

  function setInputVolume(v) { Actions.setVolume(source, v, 1) }
  function toggleOutputMute() { Actions.toggleMute(volumeSink) }
  function toggleInputMute() { Actions.toggleMute(source) }
  function toggleAllMuted() { Actions.toggleAll(volumeSink, source) }
  function setDefaultSink(node) {
    Actions.selectDevice(node, true, Pipewire, command => Quickshell.execDetached(command))
  }
  function setDefaultSource(node) {
    Actions.selectDevice(node, false, Pipewire, command => Quickshell.execDetached(command))
  }

  function sinkAvailable(node) {
    if (!node || !node.name || !sinkAvailabilityLoaded) return true
    var name = String(node.name)
    return sinkAvailability[name] !== false
  }

  function updateSinkAvailability(raw) {
    sinkAvailability = Model.parseSinkAvailability(raw)
    sinkAvailabilityLoaded = true
  }


  function nodeLabel(node) {
    return Model.nodeLabel(node)
  }


  function isHeadphones(node) {
    return Model.isHeadphones(node)
  }

  function sinkGlyph(node) {
    return Model.sinkGlyph(node)
  }

  function sourceGlyph(node) {
    return Model.sourceGlyph(node)
  }











  function streamLabel(node) {
    return Model.streamLabel(node, mprisPlayers, displayAudioStreams)
  }

  function streamRepresentsPlayer(node, player) {
    return Model.streamRepresentsPlayer(node, player, mprisPlayers, displayAudioStreams)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  PwObjectTracker { objects: root.candidateSinks }
  PwObjectTracker { objects: root.candidateSources }
  PwObjectTracker { objects: root.audioStreams }

  PwNodePeakMonitor {
    id: inputPeakMonitor
    node: root.source
    enabled: root.opened && !!root.source
  }

  Process {
    id: sinkAvailabilityProc
    command: ["omarchy-audio-sink-availability"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateSinkAvailability(text)
    }
  }

  Process {
    id: volumeSinkProc
    command: ["omarchy-audio-output-sink"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.volumeSinkName = String(text).trim()
    }
  }

  Timer {
    interval: 5000
    running: root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!sinkAvailabilityProc.running) sinkAvailabilityProc.running = true
  }

  // Runs whether or not the panel is open: the bar shows and scrolls the output
  // volume too, so an unresolved sink there would read and change the virtual
  // tuning sink instead of the speakers.
  Timer {
    interval: 15000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.resolveVolumeSink()
  }

  Timer {
    id: audioModelRefreshTimer
    interval: 75
    repeat: false
    onTriggered: root.refreshDisplayAudioModels()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.outputIcon()
    onPressed: function(b) {
      if (b === Qt.RightButton) root.toggleAllMuted()
      else root.toggle()
    }

    onWheelMoved: function(delta) {
      if (!root.hasOutput) return
      var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
      root.wheelAccumulator = wheel.remainder
      if (wheel.steps === 0) return
      var volume = root.setOutputVolume(root.outputVolume + wheel.steps * 0.05)
      root.showVolumeOsd(volume)
    }
  }

  // Only this adapter knows Omarchy, PipeWire, and MPRIS. QuickUI receives
  // plain values and stable ids; it never writes live service objects.
  UI.Theme {
    id: tokens
    background: Color.popups.background
    surface: Color.popups.background
    foreground: root.bar ? root.bar.foreground : Color.foreground
    dark: (background.r * 0.299 + background.g * 0.587 + background.b * 0.114) < 0.5
    mutedForeground: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.65)
    surfaceHover: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)
    border: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.2)
    accent: Color.accent
    accentForeground: (accent.r * 0.299 + accent.g * 0.587 + accent.b * 0.114) > 0.55 ? "#16161e" : "#ffffff"
    fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
    fontSize: Style.font.body
    smallFontSize: Style.font.caption
    radius: Style.cornerRadius
    spacing: Style.space(6)
    padding: Style.space(10)
    controlHeight: Style.space(32)
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: mixer
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(mixer.implicitHeight, Style.space(560))

    UI.AudioMixer {
      id: mixer
      anchors.fill: parent
      theme: tokens
      panelNavigation: true
      hasOutput: root.hasOutput
      hasInput: root.hasInput
      outputVolume: root.outputVolume
      inputVolume: root.inputVolume
      outputMuted: root.outputMuted
      inputMuted: root.inputMuted
      inputPeak: inputPeakMonitor.peak
      outputGlyph: root.outputIcon()
      statusText: root.outputVolumeName(liveOutputVolume, outputMuted)
      outputs: root.displayAudioSinks.filter(node => !!node).map(node => ({
        id: String(node.id), label: root.nodeLabel(node), glyph: root.sinkGlyph(node),
        current: !!root.sink && node.id === root.sink.id
      }))
      inputs: root.displayAudioSources.filter(node => !!node).map(node => ({
        id: String(node.id), label: root.nodeLabel(node), glyph: root.sourceGlyph(node),
        current: !!root.source && node.id === root.source.id
      }))
      streams: root.displayAudioStreams.filter(node => !!node).map(node => ({
        id: String(node.id), label: root.streamLabel(node),
        volume: node.audio ? node.audio.volume : 0, muted: node.audio ? node.audio.muted : false,
        current: root.streamRepresentsPlayer(node, root.activeMediaPlayer)
      }))
      onOutputVolumeRequested: value => root.setOutputVolume(value)
      onInputVolumeRequested: value => root.setInputVolume(value)
      onOutputMuteRequested: root.toggleOutputMute()
      onInputMuteRequested: root.toggleInputMute()
      onAllMuteRequested: root.toggleAllMuted()
      onOutputSelected: id => root.setDefaultSink(root.nodeWithId(root.displayAudioSinks, id))
      onInputSelected: id => root.setDefaultSource(root.nodeWithId(root.displayAudioSources, id))
      onStreamVolumeRequested: (id, value) => root.setStreamVolume(id, value)
      onStreamMuteRequested: id => root.toggleStreamMute(id)
      onCloseRequested: root.close()
      onPanelSwitchRequested: direction => root.switchPanel(direction)
    }
  }

  // Read-only diagnostics also let native tests capture only this panel,
  // never the user's desktop or unrelated windows.
  IpcHandler {
    target: "quickui-audio"
    function status(): string {
      return JSON.stringify({opened: root.opened, hasOutput: root.hasOutput,
        hasInput: root.hasInput, outputVolume: root.outputVolume, inputVolume: root.inputVolume,
        outputMuted: root.outputMuted, inputMuted: root.inputMuted,
        outputs: mixer.outputs.length, inputs: mixer.inputs.length, streams: mixer.streams.length,
        focused: mixer.activeFocus, width: mixer.width, height: mixer.height,
        cursorActive: mixer.cursorActive, focusSection: mixer.focusSection, selectedIndex: mixer.selectedIndex,
        resolvedPhysicalOutput: root.volumeSinkName !== ""})
    }
    function capture(path: string): bool {
      if (!root.opened) return false
      // KeyboardPanel owns an opaque card around its content holder.
      // Include that card so translucent theme fills retain their real contrast.
      return mixer.parent.parent.grabToImage(result => result.saveToFile(path))
    }
  }
}
