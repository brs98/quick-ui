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

Controls.CheckBox {
    id: control
    property Theme theme: Theme {}
    property string size: "default"
    property string description: ""
    property bool multiline: false
    property bool invalid: false
    Accessible.description: description

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.spacing / 2
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    implicitHeight: Math.max(theme.heightFor(control.size), implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    indicator: Rectangle {
        id: box
        implicitWidth: Math.max(16, control.theme.heightFor(control.size) - control.theme.spacing * 2)
        implicitHeight: implicitWidth
        x: control.text || control.description ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding)
            : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: Math.min(height / 4, control.theme.radius)
        color: control.checkState !== Qt.Unchecked ? control.theme.primary
            : control.hovered ? control.theme.surfaceHover : control.theme.surface
        border.width: control.visualFocus ? control.theme.focusWidth : control.theme.borderWidth
        border.color: control.invalid ? control.theme.destructive : control.visualFocus ? control.theme.focus : control.theme.border

        // Geometric marks stay sharp without depending on a font's glyph coverage.
        Item {
            anchors.centerIn: parent
            width: box.width * 0.48
            height: box.height * 0.32
            rotation: -45
            visible: control.checkState === Qt.Checked
            Rectangle {
                width: Math.max(2, box.width * 0.09)
                height: parent.height
                color: control.theme.primaryForeground
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.max(2, box.width * 0.09)
                color: control.theme.primaryForeground
            }
        }
        Rectangle {
            anchors.centerIn: parent
            width: box.width * 0.5
            height: Math.max(2, box.width * 0.09)
            color: control.theme.primaryForeground
            visible: control.checkState === Qt.PartiallyChecked
        }
        Rectangle {
            objectName: "focusRing"
            anchors.fill: parent
            anchors.margins: -(control.theme.focusWidth + 2)
            radius: box.radius + control.theme.focusWidth + 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: control.visualFocus
        }
        Behavior on color { ColorAnimation { duration: control.theme.motionDuration } }
    }

    contentItem: Item {
        implicitWidth: Math.max(title.implicitWidth, detail.implicitWidth) + control.indicator.width + control.spacing
        implicitHeight: labels.implicitHeight
        Column {
            id: labels
            x: control.mirrored ? 0 : control.indicator.width + control.spacing
            width: Math.max(0, parent.width - control.indicator.width - control.spacing)
            anchors.verticalCenter: parent.verticalCenter
            spacing: control.description ? control.theme.spacing / 2 : 0
            Text {
                id: title
                objectName: "toggleLabel"
                width: parent.width
                text: control.text
                textFormat: Text.PlainText
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                font: control.font
                color: control.theme.foreground
                wrapMode: control.multiline ? Text.Wrap : Text.NoWrap
                elide: control.multiline ? Text.ElideNone : Text.ElideRight
            }
            Text {
                id: detail
                visible: text.length > 0
                width: parent.width
                text: control.description
                textFormat: Text.PlainText
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                font.family: control.theme.fontFamily
                font.pixelSize: control.theme.smallFontSize
                color: control.theme.mutedForeground
                wrapMode: Text.Wrap
            }
        }
    }
}
