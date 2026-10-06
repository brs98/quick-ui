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
import QtQuick.Controls.Basic as Controls

// Internal visual renderer. The public Button icon API supplies theme lookup,
// source fallback, tint, sizing and caching; it never becomes an input target.
Controls.Button {
    id: graphic
    text: ""
    display: Controls.Button.IconOnly
    enabled: false
    focusPolicy: Qt.NoFocus
    hoverEnabled: false
    Accessible.ignored: true
    padding: 0
    horizontalPadding: 0
    verticalPadding: 0
    implicitWidth: implicitContentWidth
    implicitHeight: implicitContentHeight
    icon.width: 18
    icon.height: 18
    icon.color: "transparent"
    background: null
}
