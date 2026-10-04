# Audio milestone verification

Verified on 2026-10-04 with Quickshell 0.3.1, Qt 6.11.2, Omarchy 4.0.4, and
Hyprland/Wayland on this machine.

## Delivered

Five installable entries extend the foundation to **15 components plus Theme**:
`tooltip`, `level-meter`, `device-item`, `volume-control`, and `audio-mixer`.
Quickbook includes direct canonical-source stories for all five, with 23 audio
presets and executable usage examples. The complete catalog has 19 entries:
15 components, Theme playground, and three legacy examples.

`VolumeControl` and `AudioMixer` expose controlled requests. They accept plain
values/ids; PipeWire, MPRIS, process helpers, and Omarchy window hosting live in
`integrations/omarchy-audio/`. Internal keyed models preserve delegates during
backend updates, including while dragging a stream slider.

## Evidence

- `./scripts/test`: 39 Python tests and 248 Qt test results passed; QML lint clean.
  Includes request rejection, volume bounds, native Tab focus, shell cursor keys,
  Escape signals, model removal/reorder, held dragging during array replacement,
  adapter actions, every preset in both themes, and usage compilation.
- `python3 scripts/audio_smoke.py`: actual source installation into a clean
  directory, 11-source dependency closure, customized Theme preservation, exact
  installed bytes, mock adapter actions, and native dark/light rendering passed.
- `python3 scripts/installed_smoke.py` and `python3 scripts/smoke.py`: existing
  foundation installation, workbench IPC, native screenshots, and hot reload passed.
- Real `brandon.audio` plugin loaded against the machine's output/microphone.
  Verified open/focus, first-arrow cursor reveal without changing volume,
  Tab handoff to another shell panel, Escape close/focus release, and closed-list
  detachment. Captured only the audio card with the active Omarchy theme.
- A temporary silent playback stream exercised actual PipeWire integration:
  it appeared in Applications, a keyboard volume request changed its backend
  volume from 1.00 to 0.95, and `m` toggled its backend mute state. Removing the
  stream updated the list and repaired the cursor without errors. The test stream
  was terminated; master output and microphone levels/mute states were unchanged.
- The installed adapter and all eleven installed QML files match the deliverable
  sources byte for byte. The stock Model.js is preserved unchanged.

The native popup remains Omarchy's KeyboardPanel, preserving its outside-click
handling and compositor focus policy. That host is not distributed as a QuickUI
window primitive. The native checks above exercise focus, Escape, and panel
handoff; multi-monitor outside-click behavior is inherited, not newly audited.

## Installed state and rollback

The official clone command replaced `omarchy.audio` with `brandon.audio` at its
existing position in `~/.config/omarchy/shell.json`. Plugin source lives in
`~/.config/omarchy/plugins/brandon.audio`, now a local Git repository:

- `b2d769a`: original stock clone baseline.
- `38821ab`: QuickUI adoption.

Revert the adoption commit there, then run `omarchy restart shell`, to restore
stock visuals while keeping the same placement and IPC. The pre-adoption shell
configuration is also backed up in
`~/.local/state/quickui-audio-adoption/shell-before.json`; restoring it wholesale
would discard later shell config edits, so prefer the plugin revert.

The shell retained a cached old component after plugin rescans during installation;
a normal shell restart applied the replacement. No packaged Omarchy files changed.

## Follow-up distribution work

The local milestone is complete. Public distribution still needs a license and
upstream integration-source attribution review, a versioned remote registry,
reviewed source updates/diffs, and compatibility testing across Qt/Quickshell and
compositors. Screen-reader auditing and further shell blocks remain future work.
