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

Controls.TextField {
    id: control
    property Theme theme: Theme {}
    property bool invalid: false
    property string size: "default"

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.spacing
    leftPadding: theme.paddingFor(size)
    rightPadding: theme.paddingFor(size)
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    color: theme.foreground
    placeholderTextColor: theme.mutedForeground
    selectionColor: theme.selection
    selectedTextColor: theme.selectionForeground

    background: Rectangle {
        implicitWidth: control.theme.heightFor(control.size) * 6
        implicitHeight: control.theme.heightFor(control.size)
        radius: control.theme.radius
        color: control.theme.surface
        border.width: control.activeFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.invalid ? control.theme.destructive : control.activeFocus ? control.theme.focus
            : control.hovered ? control.theme.mutedForeground : control.theme.border
        Behavior on border.color { ColorAnimation { duration: control.theme.motionDuration } }
    }
}
