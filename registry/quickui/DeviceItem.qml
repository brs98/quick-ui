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

Controls.ItemDelegate {
    id: control
    property Theme theme: Theme {}
    property string glyph: ""
    property string description: ""
    property bool current: false
    property bool cursorHighlighted: false
    implicitWidth: 280
    implicitHeight: Math.max(theme.controlHeight, implicitContentHeight + topPadding + bottomPadding)
    padding: theme.spacing
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    Accessible.role: Accessible.ListItem
    Accessible.selectable: true
    Accessible.focusable: enabled && focusPolicy !== Qt.NoFocus
    Accessible.onPressAction: control.click()
    Accessible.selected: current
    Accessible.name: text
    Accessible.description: [description, current ? qsTr("Current device") : ""].filter(part => part.length > 0).join(". ")
    contentItem: Row {
        // Control.mirrored already includes inherited LayoutMirroring.
        LayoutMirroring.enabled: false
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
        spacing: control.spacing
        Text {
            objectName: "deviceGlyph"
            width: visible ? control.font.pixelSize * 1.5 : 0
            visible: control.glyph.length > 0
            text: control.glyph
            textFormat: Text.PlainText
            font: control.font
            color: control.theme.mutedForeground
            Accessible.ignored: true
        }
        Column {
            spacing: Math.max(2, control.theme.spacing / 2)
            width: Math.max(0, control.availableWidth - (control.glyph.length ? control.font.pixelSize * 1.5 + control.spacing : 0) - indicator.width - control.spacing)
            Text {
                width: parent.width
                text: control.text
                textFormat: Text.PlainText
                font: control.font
                color: control.theme.foreground
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                elide: Text.ElideRight
                Accessible.ignored: true
            }
            Text {
                objectName: "deviceDescription"
                width: parent.width
                visible: text.length > 0
                text: control.description
                textFormat: Text.PlainText
                font.family: control.font.family
                font.pixelSize: control.theme.smallFontSize
                color: control.theme.mutedForeground
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                wrapMode: Text.Wrap
                Accessible.ignored: true
            }
        }
        Text {
            id: indicator
            objectName: "deviceCurrentMark"
            width: control.font.pixelSize * 1.5
            text: control.current ? "✓" : ""
            font: control.font
            color: control.theme.accent
            Accessible.ignored: true
        }
    }
    background: Rectangle {
        radius: control.theme.radius
        color: control.down || control.hovered || control.current ? control.theme.surfaceHover : control.theme.surface
        border.width: control.visualFocus || control.cursorHighlighted ? control.theme.focusWidth : 0
        border.color: control.theme.focus
    }
}
