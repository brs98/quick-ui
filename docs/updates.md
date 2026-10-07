# Reviewing and updating copied sources

QuickUI files belong to your project. The CLI compares them against the local
checkout's bundled registry; it never fetches a registry or changes versions
implicitly. Check out the desired QuickUI release first, then review your project:

```sh
./quickui diff --cwd /path/to/shell
./quickui diff button slider --cwd /path/to/shell
./quickui update --cwd /path/to/shell --dry-run
./quickui update --cwd /path/to/shell
```

Names include their transitive dependencies. Omitting names selects all installed
registry entries. Newly required dependencies can be created, but unrelated files
at their destination block the whole update. Missing tracked sources can be
restored. A changed `componentsDir` cannot silently move installed sources.

`diff` prints unified **local → bundled** differences and ownership states:

| State | Meaning | Update behavior |
| --- | --- | --- |
| current | Local bytes match this checkout | Retain bytes and modification time |
| update available | Local bytes match their installed fingerprint | Replace transactionally |
| customized; upstream unchanged | Your edits differ; bundled source still matches the installed fingerprint | Preserve edits and origin record |
| review required | Both local and bundled sources differ from the installed fingerprint | Refuse the whole batch pending review |
| missing / new dependency | Tracked file is missing, or a required source has no destination yet | Create from bundled source |
| unowned | Existing file has no matching installed record | Refuse the whole batch |
| integration-managed | Optional Omarchy installer tracks the same destination | Preserve; use its recipe installer separately |

Invalid sources, metadata, unsafe paths, corrupt snapshots, and unowned conflicts
are checked before writing. A review-required file blocks **all** updates in its
batch by default, including otherwise pristine files. Nothing is silently merged
into running shell sources, and there is no force-overwrite flag.

## Review a merge proposal

New source installs retain exact pristine bytes under `.quickui/bases/<sha256>`.
Keep this directory and `quickui.json` with your project. `.quickui` is reserved
for source snapshots and cannot be used as `componentsDir`. The hash-named snapshots
are checked before use; they are not runtime dependencies of your shell.

```sh
./quickui diff button --cwd /path/to/shell --proposals reviews/quickui-upgrade --dry-run
./quickui diff button --cwd /path/to/shell --proposals reviews/quickui-upgrade
```

Choose a **fresh project-relative directory** outside your components and
`.quickui` directories. Proposal generation never changes live QML, fingerprints,
or existing review directories. Each changed component gets:

- `local.qml`: current project source, when present.
- `bundled.qml`: source from this checkout.
- `base.qml`: verified original installed source, when retained.
- `merged.qml`: conservative three-way proposal, when both local and base exist.

`review.json` records source paths, hashes, ownership, base availability, and
conflict counts. Disjoint edits and identical changes merge automatically in the
**proposal**. Ambiguous overlapping edits use `<<<<<<< local`, `||||||| installed
base`, `=======`, and `>>>>>>> bundled` conflict hunks there. Resolve every hunk,
review even conflict-free results, and test your resulting QML before copying the
approved bytes manually to the recorded live path. A conflict-free text merge
cannot establish QML API compatibility.

After reviewing the customized files, explicitly keep them while updating the
remaining pristine sources:

```sh
./quickui update button --cwd /path/to/shell --keep-customized --dry-run
./quickui update button --cwd /path/to/shell --keep-customized
```

`--keep-customized` skips reviewed/customized files unchanged, even if this
checkout contains upstream changes to them. It does not install the proposal or
claim that skipped changes were applied. Unowned files and other validation errors
still block the whole transaction. Verify that your custom dependencies support
new component APIs before making this choice.

Customized files retain their original installed fingerprint and base. Future
reviews continue from that historical base; the CLI does not claim your manual
merge is pristine upstream source. A local file that exactly matches the bundled
source can be recorded at that bundled revision by a normal `update`.

## Older projects and separate adapters

Existing schema-version-1 manifests remain supported. If a snapshot is missing,
`diff` still works and proposals contain local/bundled copies for manual review,
but no invented base or three-way result. A pristine legacy source can still be
updated because its recorded SHA-256 verifies its provenance. Edited source is
never saved as an assumed pristine baseline.

Core source updates do not regenerate `PresetTheme.qml`, `OmarchyPreset.qml`, or
the optional `quickui-omarchy/` integration. Apply those through `preset apply` or
`omarchy install --recipe`, using their own ownership checks. If HostTheme is
tracked by the Omarchy integration, the core updater leaves it to that installer.
Existing `q1` preset codes and their meaning are unaffected.

All writes in an install/update/proposal batch are staged and then committed with
rollback if a filesystem operation fails or the command is interrupted. Original
bytes are staged before replacement; rollback restores them by rename instead of
truncating live files. If recovery itself fails, the CLI reports the retained
`.quickui-backup-*` path so you can restore the original after fixing the disk
problem. Files that change after planning are
rejected. Dry runs create neither files nor directories; repeat no-op updates
preserve source and metadata modification times. Keep normal version-control
backups: process termination or machine failure cannot be made transactionally
atomic across several filesystem paths.
