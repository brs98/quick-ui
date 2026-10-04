# QuickUI + Quickbook

QuickUI is an editable-source component library for Quickshell. Quickbook is its
native workbench: browse the real components, change inputs and themes, try presets,
and inspect events.

## Install components into your shell

Requires Python 3 for the CLI, and Quickshell with Qt 6 Quick Controls at runtime.
From this repository:

```sh
mkdir -p ~/my-shell
./quickui init --cwd ~/my-shell
./quickui add button text-field switch --cwd ~/my-shell
```

This copies QML into `~/my-shell/ui/` and records installed components in
`quickui.json`. The files belong to your project; edit them freely. No Quickbook,
Omarchy, build step, network service, or registry is needed to run the installed UI.

Inside your own window, use ordinary QML imports and share a theme:

```qml
import QtQuick
import "ui" as UI

Item {
    UI.Theme { id: tokens; dark: true; accent: "#72dce8"; radius: 10 }
    UI.Button {
        theme: tokens
        text: "Save changes"
        onClicked: console.log("Save requested")
    }
}
```

The first library contains **10 primitives**: `button`, `icon-button`, `text-field`,
`switch`, `checkbox`, `slider`, `select`, `card`, `badge`, and `separator`, plus
`theme`. `./quickui list` shows their source files and dependencies.

`add` preserves recorded, customized dependencies and refuses to overwrite edited
explicit targets or unrelated files. `--dry-run` previews installation. This is a
local bundled registry; remote publishing and automated upgrades are future work.
See [installer behavior](docs/installer.md), [component APIs](docs/components.md),
and [the library contract](docs/library-contract.md).

## Try a standalone shell

A ready-to-run installation lives at `~/personal/quickui-demo` on this machine:

```sh
WAYLAND_DISPLAY=wayland-1 quickshell -p ~/personal/quickui-demo
```

Alternatively, run `quickshell -p ~/personal/quickui-demo` from a graphical terminal.
To reproduce the installation elsewhere, create a directory, run `quickui init`,
add all ten components, and copy `templates/starter.qml` to that directory as
`shell.qml`. The starter uses mock data and has no desktop service side effects.

## First real-shell adoption

The user-owned Omarchy News plugin at `~/src/omarchy-news` now imports its footer
button and divider from its own installed `ui/` sources. Its local Theme adapter
maps Omarchy colors and sizing into QuickUI without putting Omarchy dependencies
in the component library. Adoption commit: `7aa2961` (revert that commit in the
plugin repository to restore the previous widgets).


## Run the workbench

Requires **Quickshell 0.3.1** and **Qt 6 with Qt Quick Controls**. These are already installed on the machine where this project was built. No Node dependencies or build step.

```sh
cd ~/personal/quickbook
./quickbook
```

Closing the window exits the app. The launcher also works from a Herdr or other multiplexer session that did not inherit the desktop environment: when `DISPLAY`, `WAYLAND_DISPLAY`, and `QT_QPA_PLATFORM` are unset, it selects the single Wayland socket owned by your user in `XDG_RUNTIME_DIR` (or `/run/user/$(id -u)`). If none or several are found, it prints an actionable error. Select a session explicitly with, for example, `WAYLAND_DISPLAY=wayland-1 ./quickbook`.

Explicit display and Qt platform settings are preserved, including `QT_QPA_PLATFORM=offscreen` for automation. Help, version, and Quickshell inspection commands work without a display. You can also run `quickshell -p /path/to/quickbook` directly from a terminal that already has the graphical session's environment.

## What’s included

- Direct previews for all ten QuickUI primitives, a shared-theme playground, and three clearly labeled example blocks.
- Compact layout for narrow tiled windows; use **Components** or `Ctrl+K` to browse.
- Light/dark presets and explicit text, boolean, number, and select controls.
- A Usage tab with install commands and QML snippets for every library entry.
- Dark/light themes, canvas grid, compact/wide widths, and height presets.
- A live event log (latest 100 events) and selectable JSON arguments.
- Reset to the selected preset, automatic QML reload, and a manual reload button.
- IPC for selecting stories, setting controls, and exporting native PNG screenshots.

The previews use the exact QML files distributed by the installer. The examples use mock data. Volume and notification interactions never change your desktop services.

| Shortcut | Action |
| --- | --- |
| `Ctrl+K` | Focus component search |
| `Ctrl+R` | Reload the QML configuration |
| `Ctrl+0` | Reset the selected preset |

Selecting a different component clears its event log and selects its first preset. Reset restores arguments and story-local state. Reloading starts a fresh explorer session, including selection and theme.

## Add your component

Create a wrapper in `stories/`. A story is a normal Qt Quick `Item` with this small contract:

```qml
// stories/SaveButtonStory.qml
import QtQuick
import "../registry/quickui" as UI

Item {
    id: root
    property var args: ({})
    property bool dark: true
    signal eventRaised(string name, var payload)
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    UI.Button {
        id: button
        anchors.fill: parent
        text: root.args.label ?? "Save"
        theme: UI.Theme { dark: root.dark }
        enabled: root.args.disabled !== true
        onClicked: root.eventRaised("clicked", {label: text})
    }
}
```

Append its metadata to `entries` in `stories/Catalog.qml`:

```qml
{
    id: "save-button", // Unique and stable; also used by IPC.
    group: "My library",
    title: "Save button",
    description: "The save action used in settings.",
    source: Qt.resolvedUrl("SaveButtonStory.qml"),
    controls: [
        {key: "label", label: "Label", type: "text"},
        {key: "disabled", label: "Disabled", type: "boolean"}
    ],
    presets: [
        {name: "Ready", args: {label: "Save", disabled: false}},
        {name: "Disabled", args: {label: "Save", disabled: true}}
    ]
}
```

Save and the explorer reloads. Import your real components in the wrapper; they do not need to depend on Quickbook.

Control metadata:

| Type | Value | Additional metadata |
| --- | --- | --- |
| `text` | string | — |
| `boolean` | boolean | — |
| `number` | finite number | `min`, `max`, `step` (slider increment) |
| `select` | string | `options: ["one", "two"]` |

Give each story at least one preset and supply the complete initial argument set in every preset. The explorer validates edits, clamps numeric bounds, and replaces the argument object when a control changes. Presets should contain plain JSON values. For interactive state owned by a wrapper, reset that state in `onArgsChanged`; see `VolumeStory.qml`.

Set sensible `implicitWidth` and `implicitHeight` values. The explorer fits the story within the chosen canvas, shrinking it when necessary; use ordinary responsive QML layouts inside your component. Canvas sizes are capped to available space and the actual dimensions appear underneath.

For components that currently access PipeWire, notification services, or compositor state directly, move visual inputs into properties and forward actions through signals. Supply fixtures in your story wrapper and real service values in your desktop shell.

## Automation and screenshots

With Quickbook running, execute from its project directory:

```sh
quickshell ipc -p "$PWD" call quickbook status
quickshell ipc -p "$PWD" call quickbook select volume-card
quickshell ipc -p "$PWD" call quickbook preset 2
quickshell ipc -p "$PWD" call quickbook control volume '42'
quickshell ipc -p "$PWD" call quickbook control deviceName '"Headphones"'
quickshell ipc -p "$PWD" call quickbook theme false
quickshell ipc -p "$PWD" call quickbook reset
quickshell ipc -p "$PWD" call quickbook capture "$PWD/artifacts/preview.png"
```

`control` takes a JSON value. Invalid IDs, indices, properties, or values return `false`. `capture` returns whether the asynchronous capture started; completion or a save error is logged to the launching terminal. The destination directory must exist. Add `--any-display` before `call` when addressing an offscreen instance.

## Validate

Qt 6 development tools and Python 3 are needed for the checks. On Arch, Qt 5 tools can share the same executable names; the test runner prefers `/usr/lib/qt6/bin`.

```sh
./scripts/test
python3 scripts/smoke.py
python3 scripts/installed_smoke.py
```

The first command runs launcher and installer regressions, QML lint, and Qt Quick interaction tests, including all primitive presets and both themes. The launcher tests use temporary sockets and a stub executable to verify display discovery and command forwarding without starting Qt. The smoke check starts a separate Quickshell process using the software offscreen renderer, exercises IPC and hot reload in a temporary config, and writes `artifacts/quickbook-dark.png` and `artifacts/quickbook-light.png`. It does not need an active desktop and does not affect any running Quickbook instance. The installed-source smoke test independently copies all ten primitives into a fresh project, edits its Theme, launches the standalone starter, and captures `artifacts/quickui-starter.png`.

## Project map

- `registry/quickui/`: canonical distributable QML source.
- `registry.json` and `quickui`: dependency registry and source installer.
- `templates/starter.qml`: standalone consumer using all ten primitives.
- `shell.qml`: native workbench window and IPC bridge.
- `app/Explorer.qml`: browser, canvas, controls, and event inspector.
- `app/ExplorerState.qml`: selection, presets, input validation, and event history.
- `app/ControlEditor.qml`: editors generated from control metadata.
- `stories/Catalog.qml` and `stories/primitives/`: explicit story registration and direct primitive previews.
- `stories/*Story.qml`: adapters between real components and story inputs/events.
- `examples/`: independent reusable QML components with no desktop service dependencies.

This first version previews visual Qt Quick items. Actual `PanelWindow`/`PopupWindow` stories need a separate window harness and are not embedded in the canvas. Story discovery and control metadata are explicit; automatic introspection, persisted sessions, screenshot diffing, and web publishing are not included.
