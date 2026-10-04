# Omarchy audio adapter

This user-owned replacement renders the complete audio panel with installed
QuickUI source. `Panel.qml` hosts `UI.AudioMixer` inside Omarchy's existing
`KeyboardPanel`; the packaged shell is unchanged. It retains the bar icon,
right-click master mute, accumulated wheel volume/OSD, panel switching, outside
click dismissal and the `omarchy.audio` IPC target.

## Service boundary

`Panel.qml`, `Model.js`, and `Actions.js` belong to the Omarchy integration, not the
QuickUI registry. The adapter owns PipeWire/MPRIS, device filtering and friendly
labels, default device helpers, physical output resolution through DSP sinks,
node tracking, and the microphone monitor. The mixer receives plain values and
stable string ids. Its requests are looked up against the current displayed
snapshot before touching a node, so stale device requests are harmless.

Output and microphone volumes clamp to 0–1; application streams allow 0–1.5.
The microphone peak monitor runs only while open. Displayed lists are refreshed
after a 75 ms delay and detached when closed, preserving the stock plugin's
PipeWire removal safety measures. Physical output resolution also runs while
closed so the bar wheel continues to control the actual speakers.

This adapter derives from Omarchy 4.0.4's packaged
`shell/plugins/panels/audio/Panel.qml` and `Model.js`. The model retains its upstream
logic. Omarchy integration sources are separate from portable QuickUI source;
review upstream licensing and choose a project license before public distribution.

## Install on an Omarchy machine

From the QuickUI repository, first create the normal user-owned clone:

```sh
omarchy plugin clone omarchy.audio
```

Then install the mixer into that clone and replace its adapter files:

```sh
./quickui init --cwd ~/.config/omarchy/plugins/brandon.audio
./quickui add audio-mixer --cwd ~/.config/omarchy/plugins/brandon.audio
cp integrations/omarchy-audio/{Panel.qml,Model.js,Actions.js} ~/.config/omarchy/plugins/brandon.audio/
omarchy-shell shell rescanPlugins
```

The clone command chooses `<username>.audio`; substitute your own username above.
Keep its generated manifest: `omarchy.clonedFrom: "omarchy.audio"` routes existing
shell commands to the clone. Do not change the module/IPC id inside `Panel.qml`.
Back up the stock clone and shell configuration before replacing the files.

On this machine, the installed clone and its original baseline are tracked in a
local Git repository. The adoption commit can be reverted to restore the original
panel while retaining the same bar placement and IPC. To return to the packaged
plugin entirely, enable `omarchy.audio` with the normal Omarchy plugin command.

## Verify

```sh
omarchy-shell omarchy.audio open
omarchy-shell quickui-audio status
omarchy-shell quickui-audio capture /absolute/path/audio.png
omarchy-shell omarchy.audio close
```

Diagnostics report counts and state, without application titles or device names.
Capture renders only mixer content, not the desktop. Native window hosting and
outside-click focus behavior remain the responsibility of Omarchy's KeyboardPanel;
QuickUI's standalone mixer also supports ordinary Tab navigation.
