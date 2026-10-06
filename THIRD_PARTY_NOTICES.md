# Third-party notices

QuickUI's project license is [MIT](LICENSE). The upstream notices below also
apply to the identified integration sources and must accompany their
redistribution.

## Omarchy audio integration

Copyright (c) David Heinemeier Hansson

The example in `integrations/omarchy-audio/` derives from the audio panel shipped
with **Omarchy 4.0.4**. Omarchy is MIT-licensed. Its complete, unchanged copyright
and permission notice is retained in
[integrations/omarchy-audio/LICENSE.omarchy](integrations/omarchy-audio/LICENSE.omarchy).

| QuickUI file | Upstream source / relationship |
| --- | --- |
| `integrations/omarchy-audio/Panel.qml` | Adapted from `shell/plugins/panels/audio/Panel.qml`; retains service and host integration code. |
| `integrations/omarchy-audio/Model.js` | Copied from the packaged `shell/plugins/panels/audio/Model.js`, with an attribution header added. |
| `integrations/omarchy-audio/Actions.js` | Audio mutations extracted and adapted from the upstream panel into a testable adapter. |
| `integrations/omarchy-audio/manifest.json` | Adapted audio-plugin metadata identifying the example and its Omarchy origin. |

Sources: [Omarchy v4.0.4](https://github.com/omacom/omarchy/tree/v4.0.4),
[audio panel directory](https://github.com/omacom/omarchy/tree/v4.0.4/shell/plugins/panels/audio),
[upstream license](https://github.com/omacom/omarchy/blob/v4.0.4/LICENSE).
The QuickUI adaptations replace the panel's presentation with portable
components while retaining its service integration. This is an independent
example, not an official Omarchy release.

When copying the integration, include `LICENSE.omarchy` alongside its sources
and retain the applicable QuickUI license notice.

## Runtime dependencies

The QML components import Qt's public APIs, including `QtQuick.Controls.Basic`.
The explorer and Quickshell examples also use Quickshell. Their runtime
implementations are installed separately; this repository does not redistribute
Qt or Quickshell binaries or vendor their implementation source trees. QuickUI's
MIT license does not replace their licenses.

- **Qt:** licensing depends on the Qt modules and distribution used. Consult
  [Qt licensing](https://doc.qt.io/qt-6/licensing.html) and the notices distributed
  with your Qt installation. In particular, Qt's Basic style implementation
  files carry their own licensing terms; importing and customizing controls does
  not relicense those upstream files as MIT.
- **Quickshell:** consult the project's
  [LGPLv3 license](https://github.com/quickshell-mirror/quickshell/blob/master/LICENSE)
  and the notices accompanying your installed build.
- **System icons and fonts:** examples can request installed theme icons or use
  glyphs from installed fonts. Those assets retain their own licenses; the
  runtime's icon themes and font files are not included here.

Distributors who bundle these runtimes or external assets must also include the
corresponding upstream notices and satisfy their distribution terms.
