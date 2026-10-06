# Omarchy audio adapter

This optional integration renders Omarchy's audio panel with installed QuickUI
source. `Panel.qml` hosts `UI.AudioMixer` inside Omarchy's existing `KeyboardPanel`
and retains the bar icon, right-click master mute, wheel volume/OSD, panel
switching, outside-click dismissal, and `omarchy.audio` IPC target. Installation
uses a user-owned plugin clone; it does not replace packaged shell files.

## Requirements and service boundary

The adapter was developed against Omarchy 4.0.4, Quickshell 0.3.1, and Qt 6.11.2.
It requires Omarchy's `qs.Ui` and `qs.Commons` modules, its audio helper commands,
and Quickshell's PipeWire/MPRIS services. These are integration dependencies, not
requirements of the portable QuickUI components. Other Omarchy versions need
validation against their shell APIs; this is not a standalone Quickshell panel.
For a service-free example, see [the mock audio starter](../../templates/audio.qml).

`Panel.qml`, `Model.js`, and `Actions.js` own device filtering and friendly labels,
default-device helpers, physical output resolution through DSP sinks, node
tracking, and the microphone monitor. The mixer receives plain values and stable
string ids. Requests resolve against the current displayed snapshot before
changing a node, so requests for removed devices or streams are ignored.

Output and microphone volumes clamp to 0–1; application streams allow 0–1.5.
The microphone peak monitor runs only while open. Displayed lists are refreshed
after a 75 ms delay and detached when closed, preserving the stock plugin's
PipeWire removal precautions. Physical output resolution also runs while closed
so the bar wheel can control the physical output.

The integration derives from Omarchy 4.0.4's packaged audio plugin. See
[third-party notices](../../THIRD_PARTY_NOTICES.md) and the retained
[Omarchy MIT license](LICENSE.omarchy) for attribution and license terms.

## Install into a user-owned clone

Back up your existing audio plugin, if any, and shell configuration before
installing. From the QuickUI repository, create a clone using Omarchy's command:

```sh
omarchy plugin clone omarchy.audio
```

This command also replaces the enabled stock plugin with the clone. Set the
variable below to the clone directory reported by Omarchy, normally
`~/.config/omarchy/plugins/<username>.audio`. If you already have a customized
clone, use its directory and review the three adapter files before replacing them.

```sh
audio_plugin_dir="/absolute/path/to/your/audio-plugin"
./quickui init --cwd "$audio_plugin_dir"
./quickui add audio-mixer --cwd "$audio_plugin_dir"
cp integrations/omarchy-audio/Panel.qml integrations/omarchy-audio/Model.js integrations/omarchy-audio/Actions.js "$audio_plugin_dir/"
cp integrations/omarchy-audio/LICENSE.omarchy "$audio_plugin_dir/"
cp LICENSE "$audio_plugin_dir/LICENSE.quickui"
omarchy-shell shell rescanPlugins
```

Keep the clone-generated `manifest.json`. Its `omarchy.clonedFrom` value of
`"omarchy.audio"` routes existing shell commands to the clone. The manifest in
this directory uses the neutral example id `quickui.audio` and is a reference,
not a replacement for your generated manifest. Keep the module and IPC identity
inside `Panel.qml` as `omarchy.audio` as well.

If a rescan retains the old QML component, `omarchy restart shell` clears the
shell's component cache. To undo the replacement while keeping the clone and its
bar placement, restore the plugin files from your backup and restart the shell.
To return to the packaged plugin, enable `omarchy.audio` through Omarchy's plugin
management. Restore shell configuration selectively if other settings have changed.

## Inspect the installed panel

```sh
omarchy-shell omarchy.audio open
omarchy-shell quickui-audio status
omarchy-shell quickui-audio capture /absolute/path/audio.png
omarchy-shell omarchy.audio close
```

Status reports counts and state without application titles or device names.
Capture requires an open panel and renders only the audio card, including its
visible labels. It saves asynchronously; check that the image was written.

Omarchy's `KeyboardPanel` owns window focus and outside-click dismissal. The
adapter enables panel navigation: the first arrow reveals the cursor without
changing volume, Tab/Shift+Tab switch panels, and Escape closes. The standalone
mixer instead defaults to normal Tab traversal. See the
[audio validation guide](../../docs/audio-milestone.md) for automated coverage
and host checks.
