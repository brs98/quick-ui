# AudioMixer

`AudioMixer` composes QuickUI source components into an audio panel. It has no
PipeWire, compositor, process, or Omarchy imports. Supply snapshots and handle
requests in an adapter. IDs are unique opaque strings within each list; replace arrays to publish changes.
Internal keyed models retain the same native controls across snapshot updates and
reordering, preserving pointer drags and keyboard focus.

```qml
AudioMixer {
    theme: appearance
    outputs: [{id: "speakers", label: "Speakers", glyph: "♪", current: true}]
    inputs: []
    streams: [{id: "music", label: "Music", volume: 0.7, muted: false, current: true}]
    hasOutput: true
    outputVolume: app.volume
    outputMuted: app.muted
    onOutputVolumeRequested: value => app.volume = value
    onOutputMuteRequested: app.muted = !app.muted
}
```

The snippet assumes the installed directory is imported and the consumer defines
`appearance` and `app`. Device snapshots have `id`, `label`, optional `glyph` and
`description`, and `current`.
Streams have `id`, `label`, `volume`, `muted`, and `current`. The current device and
active application are visual state supplied by the consumer; selecting a row
only emits a request.

Properties are `theme`, `outputs`, `inputs`, `streams`, `hasOutput`, `hasInput`,
`outputVolume`, `inputVolume`, `outputMuted`, `inputMuted`, `inputPeak`,
`outputGlyph`, `statusText`, and `panelNavigation`. `liveOutputVolume` is read-only
and follows the output thumb during dragging, useful for a live status label.
Default width is 380; implicit height is the full content height. Set a bounded
`height` to enable vertical scrolling. Missing output devices have an explicit
placeholder; the input section appears when an input or input choice exists.

Requests are `outputVolumeRequested(value)`, `inputVolumeRequested(value)`,
`outputMuteRequested()`, `inputMuteRequested()`, `allMuteRequested()`,
`outputSelected(id)`, `inputSelected(id)`, `streamVolumeRequested(id, value)`,
`streamMuteRequested(id)`, `closeRequested()`, and `panelSwitchRequested(direction)`.
Output/input requests stay between 0 and 1; application requests stay between 0
and 1.5. Volume and mute changes remain owned by the consumer, including rejected
requests. Peak values are visual feedback only.

By default, Tab traverses native controls and their usual keyboard interaction
applies. Escape requests dismissal. Set `panelNavigation: true` for a shell panel:

| Key | Behavior |
| --- | --- |
| j/k, Down/Up | Move through header, output, devices, input, and applications |
| h/l, Left/Right | Adjust the selected volume by 5%; device rows do nothing |
| Enter/Space | Toggle selected mute control or select a device |
| m | Toggle the focused section's mute, or the focused application |
| Tab/Shift+Tab | Request the next/previous shell panel |
| Escape | Request dismissal |

The first directional key reveals the cursor without moving or changing volume.
The header activation requests muting/unmuting all channels; `m` on the header
requests output mute, matching the stock shell behavior. Navigation stays within
the list ends. Pointer hover updates the same cursor. Focused rows scroll into
view, and model changes repair a cursor that would otherwise point outside its
section. The public `focusSection`, `selectedIndex`, and `cursorActive` properties
can be inspected for announcements or testing.

`cursorLabel` describes the current channel/device, value, and mute state. In panel
navigation mode the focused keyboard item exposes this name and key instructions
through Qt accessibility. Native mode scrolls the actual focused child into view
when a row is taller than the viewport, including after resizing or model changes.
The Input heading stays visible when input choices exist without a default source.
Master-switch tooltips support hover, native keyboard focus, and the panel cursor.

Call `reset()` when a shell panel opens. It returns the cursor to the output row,
hides the cursor, resets scroll to the top, and focuses panel keyboard handling
when enabled. It does not mutate device state or reopen a dismissed window.

Runtime tests cover both keyboard modes, pointer requests, disabled controls,
controlled mute, signal IDs and bounds, live model changes, scrolling, theme
sharing, current device/application state, and peak forwarding.
