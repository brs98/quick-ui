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

Controls.ToolTip {
    id: control
    property Theme theme: Theme {}
    // Native x/y and popup edge flipping remain available to callers.
    property real maximumWidth: 320
    property string placement: "top"
    property real offset: theme.spacing / 2
    width: Math.min(implicitWidth, maximumWidth > 0 ? maximumWidth : implicitWidth)
    x: parent ? (parent.width - width) / 2 : 0
    y: placement === "bottom" && parent ? parent.height + offset : -height - offset
    delay: 600
    timeout: 4000
    font.family: theme.fontFamily
    font.pixelSize: theme.smallFontSize
    padding: theme.spacing
    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.theme.popupForeground
        wrapMode: Text.Wrap
    }
    background: Rectangle {
        color: control.theme.popup
        radius: control.theme.radius
        border.color: control.theme.border
        border.width: control.theme.borderWidth
    }
}
