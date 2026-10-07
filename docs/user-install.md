# Install QuickUI and Quickbook for your user

Use a QuickUI release source archive or a checkout. The installer copies a complete,
self-contained snapshot: you can move or delete the extracted source afterward.
Git is not needed when installing from an archive or using the installed tools.

Requirements: Linux, Python 3.8+, Bash, and Quickshell with Qt 6.10+ Quick Controls
for Quickbook. The component CLI needs only Python. This does not install system
packages or change your shell or Omarchy configuration.

From the extracted release or checkout:

```sh
python3 scripts/install.py --dry-run
python3 scripts/install.py
~/.local/bin/quickbook
~/.local/bin/quickui list
```

Quickbook also appears in your desktop's application launcher. Choose **Create**
to design a preset or browse the component stories. If your desktop caches its
application list, refresh the launcher or sign in again.

The default prefix is `~/.local`. Add `~/.local/bin` to your shell's `PATH` to use
`quickbook` and `quickui` by name. A custom prefix is supported, including spaces:

```sh
python3 scripts/install.py --prefix "$HOME/Applications/Quick UI"
"$HOME/Applications/Quick UI/bin/quickbook"
```

For a custom prefix, add its `bin` directory to `PATH` and its `share` directory
to `XDG_DATA_DIRS` if you want your desktop to discover the application and icon.
The default `~/.local/share` location is already searched by normal desktops.

## Installed files

| Location under the prefix | Purpose |
| --- | --- |
| `bin/quickui`, `bin/quickbook` | Launchers that work from any directory |
| `share/quick-ui/` | Bundled application, registry, integrations, examples, docs, and tools |
| `share/applications/quickbook.desktop` | Desktop application entry |
| `share/icons/hicolor/scalable/apps/quickbook.svg` | Application icon |
| `share/quick-ui-install.json` | Managed file hashes and installed version |

The snapshot is managed installation content. Use `quickui init` and `quickui add`
to copy editable components into your own project; customize those copies.
Quickbook sessions and recipes live in the user's separate state directory, not
in this installation. Removing or updating this installation leaves that state
and consumer projects untouched.

## Update or remove

Extract a newer release and run its installer with the same prefix. It stages
the complete replacement before making changes, checks installed file hashes and
permissions, and rolls back completed replacements if a filesystem operation
fails. Reinstalling identical content is a no-op. This is not a power-loss-safe
transaction across the whole filesystem; avoid interrupting the installer.

The installer refuses existing unowned launchers or application files, modified
managed files, unexpected files inside its application directory, and symlinks
at installation destinations. It has no force flag. Preserve your changes and
restore the original managed files before updating; use another prefix when an
unrelated program already occupies a launcher name.

Preview and remove the managed installation with its bundled installer:

```sh
python3 ~/.local/share/quick-ui/scripts/install.py --uninstall --dry-run
python3 ~/.local/share/quick-ui/scripts/install.py --uninstall
```

For another prefix, supply `--prefix` again. Uninstallation also refuses modified
managed content. Unrelated files under the prefix are preserved.

A temporary `.quick-ui-install.lock` directory prevents concurrent installers.
If an installer is forcibly killed, first ensure no installer remains running
and inspect the prefix for a `.quick-ui-stage-*` directory containing recovery
files. Preserve those files before removing a stale lock; do not discard backups
from an interrupted replacement.
