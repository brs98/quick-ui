# Audio controls

These components use Qt Quick and Qt Quick Controls only. They know nothing about PipeWire, application streams, a shell, or service objects. Pass one shared `Theme` to keep their tokens synchronized.

| Component | API |
| --- | --- |
| `ToolTip` | Native `Controls.ToolTip` with `theme`. Supports native `text`, `parent`, `visible`, `delay` (default 600 ms), `timeout` (default 4000 ms), and dismissal. Text is always plain text. |
| `LevelMeter` | `theme`, `value` (0–1), `muted`; read-only `boundedValue`. Invalid and negative values display zero; values above one fill the meter. Defaults to 160×6. Set `Accessible.name` for context. |
| `DeviceItem` | Native `ItemDelegate` with `theme`, `text`, optional `glyph`, `current`, and `cursorHighlighted`. Emits native `clicked`; `hovered`, `activeFocus`, keyboard activation, and enabled behavior remain native. Current-device check and cursor/focus outline are distinct. Text elides. |
| `VolumeControl` | `theme`, `title`, `glyph`, `value`, `maximum` (1), `stepSize` (0.05), `muted`, `available`, `cursorHighlighted`, `active`, `showMeter`, `peak`. Emits `volumeRequested(real value)`, `muteRequested()`, and `hovered()` on entry. Read-only `dragging` and `liveValue`; `slider` and `muteButton` aliases expose native controls for focus/navigation integration. |

`VolumeControl` is controlled: it never changes its input `value` or `muted`. Handle a request and update the input only if the backend accepts it. While dragging, `liveValue` previews the native slider position; releasing restores the backend value. Keyboard edits also return to the backend value when a request is rejected. External updates remain reactive after any interaction.

```qml
UI.Theme { id: tokens }
UI.VolumeControl {
    theme: tokens
    title: "Output"
    value: audio.volume
    muted: audio.muted
    available: audio.available
    onVolumeRequested: requested => audio.setVolume(requested)
    onMuteRequested: audio.toggleMuted()
}
```

The example's `audio` is a consumer-owned adapter, not part of QuickUI. `maximum` is a linear volume ratio, so 1 means 100% and 1.5 allows 150%. Requests are bounded to zero through maximum. The slider supports native arrow/Home/End navigation and pointer dragging; wheel notches use `stepSize`, with partial wheel deltas accumulated. Right-clicking the slider requests mute. The mute button supports Tab/Space and a descriptive accessible name with a themed tooltip. A parent that owns row navigation may set `slider.focusPolicy` and `muteButton.focusPolicy` through the aliases.

`active` highlights the title (for example, a playing stream); it does not start or stop playback. `peak` drives the optional `LevelMeter` without changing volume. `available: false` disables both interactive children and dims the row.

Dependencies: `VolumeControl` requires `Slider`, `IconButton` (and `Button`), `ToolTip`, `LevelMeter`, and `Theme`. Other new components require only `Theme`.
