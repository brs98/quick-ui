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

// Use one content child (normally a ColumnLayout). Pane derives content size
// from that child; bind its width to availableWidth for wrapping.
Controls.Pane {
    id: control
    property Theme theme: Theme {}
    property string size: "default"
    padding: theme.paddingFor(size)
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    palette.windowText: theme.cardForeground
    opacity: enabled ? 1 : theme.disabledOpacity
    background: Rectangle {
        color: control.theme.card
        radius: control.theme.radiusLarge
        border.width: control.theme.borderWidth
        border.color: control.theme.border
    }
}
