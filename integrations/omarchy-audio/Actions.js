// SPDX-License-Identifier: MIT
// Copyright (c) David Heinemeier Hansson
// Adapted from Omarchy 4.0.4, shell/plugins/panels/audio/Panel.qml.
// QuickUI integration changes are covered by the project LICENSE.
// Preserve the upstream permission notice in LICENSE.omarchy when redistributing.

// Adapter actions are service-aware; reusable QuickUI components are not.
function setVolume(node, value, maximum) {
    if (!node || !node.audio) return 0
    if (!isFinite(value)) return node.audio.volume
    var next = Math.max(0, Math.min(maximum, value))
    node.audio.volume = next
    return next
}

function toggleMute(node) {
    if (node && node.audio) node.audio.muted = !node.audio.muted
}

function toggleAll(output, input) {
    var hasOutput = !!(output && output.audio)
    var hasInput = !!(input && input.audio)
    var mute = (hasOutput && !output.audio.muted) || (hasInput && !input.audio.muted)
    if (hasOutput) output.audio.muted = mute
    if (hasInput) input.audio.muted = mute
}

function nodeWithId(list, id) {
    for (var i = 0; i < list.length; i++)
        if (list[i] && String(list[i].id) === String(id)) return list[i]
    return null
}

function selectDevice(node, output, pipewire, execute) {
    if (!node) return
    if (output) pipewire.preferredDefaultAudioSink = node
    else pipewire.preferredDefaultAudioSource = node
    if (node.id !== undefined && node.name) execute([
        output ? "omarchy-audio-output-set-default" : "omarchy-audio-input-set-default",
        String(node.id), String(node.name)
    ])
}
