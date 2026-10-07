# Installing QuickUI source

QuickUI copies editable QML files from this checkout's bundled registry into your
Quickshell project. The installer needs Python 3.8+ and no Python packages or network
access after cloning. Get the installer and its bundled registry together:

```sh
git clone https://github.com/brs98/quick-ui.git
cd quick-ui
```

Run it from this repository; the resulting QML files work independently of this
checkout. Do not copy the `quickui` executable by itself: it needs the neighboring
`registry.json` and `registry/quickui/` sources. You can also run the executable by
its absolute path from another directory.

## Start with an existing project directory

```sh
mkdir -p /tmp/my-quickshell
./quickui list
./quickui init --cwd /tmp/my-quickshell --dry-run
./quickui init --cwd /tmp/my-quickshell
./quickui add button slider icon-button --cwd /tmp/my-quickshell
```

`init` creates `quickui.json` and `ui/Theme.qml`. `add` copies the requested files
and their transitive dependencies: adding `icon-button` also installs `button`
and `theme`. Commands accept multiple component names, and `--cwd` defaults to
the current directory. The project directory must already exist. The installer
does not create or edit `shell.qml`.

Run `./quickui list` for the complete catalog of 23 public components, Theme,
and the internal icon dependency. See [component APIs](components.md) for the
controls and composition recipes.

Import the copied directory from your QML file and pass a shared theme:

```qml
import QtQuick
import "ui" as UI

Rectangle {
    id: root
    width: 400
    height: 180
    color: palette.background

    UI.Theme {
        id: palette
        dark: false
        accent: "#7152cf"
    }

    UI.Button {
        anchors.centerIn: parent
        theme: palette
        text: "Hello, QuickUI"
        onClicked: console.log("Clicked")
    }
}
```

This example is window content: put it in a Quickshell window or use your existing
shell's composition. Controls use Qt Quick Controls behavior and have no Omarchy
or desktop-service dependency. Pass state and handle signals in your own shell.

## Local configuration and customization

The project configuration starts with:

```json
{
  "schemaVersion": 1,
  "componentsDir": "ui"
}
```

To use a different directory, create this configuration before `init`, or edit
`componentsDir` before installing components. Nested paths such as
`components/ui` are supported; this changes the destination of future installs
and does not move already installed files. Use the corresponding relative import
in your QML.

The installer also maintains an `installed` object in this file, recording each
component's project-relative destination and the SHA-256 fingerprint of the
bundled source it copied. Keep that metadata so later installs can distinguish
your installed dependencies from unrelated files. Other configuration fields are
preserved.

Customize theme properties on a shared `UI.Theme` instance, or edit the installed
source. You own those files. Keep their included MIT license notices when
redistributing. There is no managed runtime module or updater.
Re-adding byte-identical files is a no-op that preserves their modification times.
Previously installed dependencies are retained even after you customize them:
editing `ui/Theme.qml` and then running `add slider` installs Slider while keeping
your exact Theme bytes; editing Button and then adding IconButton likewise keeps
Button. The CLI reports each retained customized dependency.

An explicitly requested component with differing contents is refused, as is any
conflicting dependency without a matching installed-origin record at its current
path. All conflicts are checked before any write. For example, `add theme` refuses
to replace your edited Theme. To update customized source, install into a fresh
temporary project and review/merge the desired changes manually. The installer
does not verify that your customized dependency still exposes the API expected by
a new component. There is no force overwrite option.

Both `init` and `add` support `--dry-run`. A dry run performs the same validation
and conflict checks, reports planned copies, and creates no files or directories.
All expected configuration, dependency, source, destination, and conflict checks
happen before any write. An unexpected filesystem failure during writing can
still leave a partial installation; fix the failure and rerun the same command.

## Registry and path rules

`registry.json` maps registry names to QML filenames and dependency lists. Source
files live in `registry/quickui/`; installed files are exact copies. Registry
filenames must be simple QML type filenames, destinations must be relative paths
inside the selected project, and path traversal is rejected. Symlinked metadata,
source files, destination files, and directories inside the project are rejected,
including dangling links. An explicitly selected project directory itself may be
a symlink; it is resolved to its real location before validation.

The registry graph must contain only known dependencies and no cycles. Malformed
JSON and duplicate JSON keys are rejected. The CLI uses only the bundled local
registry. Select a source revision by checking out a Git tag or commit before
installing. Remote-registry fetching and automatic source merging are future work.

Exit codes: `0` for success (including no-ops and valid dry runs), `1` for an
installation/registry/filesystem error, and `2` for invalid command-line usage.
Run `./quickui --help` or `./quickui add --help` for usage.

## Installer checks

```sh
python3 -m unittest discover -s tests -p test_installer.py -v
```

The tests invoke the real executable against disposable projects and a disposable
registry fixture. They verify source copying, dependency closure, repeat
installation, dry runs, retained customized dependencies, unrelated-file
preservation, and malformed/path/symlink
failures. QML behavior is covered by the project's separate Qt tests.
