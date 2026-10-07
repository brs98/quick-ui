// SPDX-License-Identifier: MIT
/*
MIT License

Copyright (c) 2026 brs98

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import QtQuick
import "OmarchyTokens.js" as Mapper

// Inject qs.Commons.Color and qs.Commons.Style from an Omarchy shell plugin.
// No singleton imports here: standalone projects can import this module safely.
QtObject {
    id: root
    property var colorSource: null
    property var styleSource: null
    readonly property bool available: colorSource !== null && styleSource !== null
    readonly property var snapshot: !available ? null : ({
        colors: {
            background: colorSource.background,
            foreground: colorSource.foreground,
            accent: colorSource.accent,
            urgent: colorSource.urgent,
            muted: colorSource.muted,
            popup: colorSource.popups.background,
            popupForeground: colorSource.popups.text,
            border: colorSource.popups.border,
            surfaceHover: styleSource.hoverFill,
            selection: styleSource.selectedFill,
            selectionForeground: colorSource.foreground,
            focus: styleSource.focusBorderColor
        },
        style: {
            fontFamily: styleSource.font.resolvedFamily,
            fontScale: styleSource.fontScale,
            fontSize: styleSource.font.body,
            smallFontSize: styleSource.font.bodySmall,
            radius: styleSource.cornerRadius,
            spacing: styleSource.spacing.controlGap,
            padding: styleSource.spacing.controlPaddingX,
            controlHeight: styleSource.spacing.controlHeight,
            handleSize: styleSource.space(14),
            borderWidth: styleSource.normalBorderWidth,
            focusWidth: styleSource.focusBorderWidth
        }
    })
    readonly property var tokens: Mapper.resolve(snapshot)
}
