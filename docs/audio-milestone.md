# Audio integration and validation

QuickUI's audio components accept plain data and emit requests; the consumer owns
state and services. `VolumeControl` and `AudioMixer` do not import PipeWire,
MPRIS, or Omarchy. The mixer reconciles device and stream snapshots by stable id
so value updates can preserve focus and an ongoing slider drag.

Two examples exercise this boundary:

- [The audio starter](../templates/audio.qml) owns mock device and stream state
  and runs independently of Omarchy.
- [The Omarchy adapter](../integrations/omarchy-audio/README.md) connects the mixer
  to live services and uses Omarchy's window hosting and audio helpers.

Component APIs and usage recipes are documented in [the component guide](components.md).

## Reproduce automated validation

From the repository root, with Python 3, Qt 6 development tools and QtTest
installed, run:

```sh
./scripts/test
```

The suite runs installer tests, QML lint, and Qt tests using the offscreen
software backend. Relevant audio coverage includes controlled requests that an
owner may reject, volume bounds, native Tab traversal, panel cursor navigation,
Escape/panel-switch signals, hot list removal and reorder, and array replacement
during a held drag. It also checks long labels, theme changes, RTL, bounded
scrolling, accessibility properties, story presets, and executable usage examples.
The adapter's JavaScript tests use mock services to check device selection,
stale ids, mute/volume actions, labels, and playback classification.

For installation and native rendering, install Quickshell and run:

```sh
python3 scripts/audio_smoke.py --output-dir /tmp/quickui-audio-validation
```

This creates a temporary project, installs `audio-mixer` and its dependency
closure, compares installed source bytes, and verifies that a customized Theme
is preserved. It then launches an isolated Quickshell process with mock audio
state on Qt's offscreen backend, exercises IPC requests, and captures dark and
light previews. It does not launch an Omarchy panel or change real audio devices.
The dependency closure is derived from `registry.json`; counts may change as
components evolve.

Additional integration checks are available through
[`scripts/installed_smoke.py`](../scripts/installed_smoke.py) for the foundation
starter and [`scripts/smoke.py`](../scripts/smoke.py) for Quickbook's IPC, rendering,
and hot reload. These also use isolated offscreen processes.

## Validate a live Omarchy installation

The adapter was developed and exercised with Omarchy 4.0.4, Quickshell 0.3.1,
Qt 6.11.2, and Hyprland/Wayland. This is a development baseline, not a compatibility
guarantee for other shell versions or compositors. Follow the
[adapter installation instructions](../integrations/omarchy-audio/README.md)
before running live checks.

Check that the panel opens, receives focus, and displays the expected devices.
The first arrow should reveal its cursor without changing volume; subsequent
navigation should keep the selected row visible. Tab/Shift+Tab should hand off to
another shell panel, Escape should close and release focus, and outside clicks
should follow the host's dismissal behavior. The diagnostic status command can
confirm that displayed lists detach after closing.

To check the service boundary, use a disposable playback stream and verify that
its volume and mute requests affect that stream, then remove it while the panel
is open. Confirm that the list and cursor recover without warnings. Output,
microphone, and default-device requests act on real hardware: test them
intentionally and restore the prior settings afterward. Also check the bar's
wheel/OSD and right-click mute behavior in the host.

Automated tests with mock services do not establish live PipeWire or compositor
compatibility. Window placement, outside-click handling, and multi-monitor focus
remain Omarchy host behavior. Accessibility property and activation tests do not
constitute a complete screen-reader audit.

## Source and attribution

Portable components live in `registry/quickui/`; the service adapter lives in
`integrations/omarchy-audio/` and is installed separately. The latter contains code
derived from Omarchy's audio plugin. See [third-party notices](../THIRD_PARTY_NOTICES.md)
and the retained [Omarchy license](../integrations/omarchy-audio/LICENSE.omarchy).
