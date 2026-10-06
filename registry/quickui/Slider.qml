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

Controls.Slider {
    id: control
    property Theme theme: Theme {}

    padding: theme.spacing
    implicitWidth: horizontal ? 200 : Math.max(theme.controlHeight, theme.handleSize + leftPadding + rightPadding)
    implicitHeight: horizontal ? Math.max(theme.controlHeight, theme.handleSize + topPadding + bottomPadding) : 200
    opacity: enabled ? 1 : theme.disabledOpacity

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        width: control.horizontal ? control.availableWidth : 4
        height: control.horizontal ? 4 : control.availableHeight
        radius: 2
        color: control.theme.border

        Rectangle {
            x: control.horizontal && control.mirrored ? parent.width - width : 0
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : parent.width
            height: control.horizontal ? parent.height : control.position * parent.height
            radius: 2
            color: control.theme.primary
        }
    }

    handle: Rectangle {
        id: thumb
        implicitWidth: control.theme.handleSize
        implicitHeight: implicitWidth
        x: control.leftPadding + (control.horizontal
            ? control.visualPosition * (control.availableWidth - width)
            : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal
            ? (control.availableHeight - height) / 2
            : control.visualPosition * (control.availableHeight - height))
        radius: width / 2
        color: control.pressed ? control.theme.primary : control.theme.surface
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.visualFocus ? control.theme.focus : control.theme.primary
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: width / 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: control.visualFocus
        }
    }
}
