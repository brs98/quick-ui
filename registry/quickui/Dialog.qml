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

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls

// Native popup ownership, result signals and focus restoration are preserved.
Controls.Dialog {
    id: control
    property Theme theme: Theme {}
    property string size: "default"

    modal: true
    focus: true
    popupType: Controls.Popup.Item
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside
    padding: theme.paddingFor(size) * 1.5
    spacing: theme.spacing
    margins: theme.spacing * 2
    width: Math.min(implicitWidth, parent ? Math.max(0, parent.width - margins * 2) : implicitWidth)
    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: parent ? Math.max(margins, Math.round((parent.height - height) / 2)) : 0
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    palette.window: theme.popup
    palette.windowText: theme.popupForeground

    // Popup is a QObject; accessibility belongs to its public visual item.
    Binding { target: control.contentItem.parent; property: "Accessible.role"; value: Accessible.Dialog }
    Binding { target: control.contentItem.parent; property: "Accessible.name"; value: control.title }

    background: Rectangle {
        implicitWidth: 360
        color: control.theme.popup
        radius: control.theme.radiusLarge
        border.color: control.theme.border
        border.width: control.theme.borderWidth
    }
    header: Item {
        visible: control.title.length > 0
        implicitWidth: titleMetrics.advanceWidth + control.padding * 2
        implicitHeight: heading.implicitHeight + control.padding
        TextMetrics { id: titleMetrics; text: control.title; font: heading.font }
        Text {
            id: heading
            x: control.padding
            y: control.padding
            width: Math.max(0, parent.width - control.padding * 2)
            text: control.title
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            font.family: control.font.family
            font.pixelSize: control.font.pixelSize
            font.bold: true
            color: control.theme.popupForeground
        }
    }
    footer: Controls.DialogButtonBox {
        id: buttons
        implicitWidth: {
            let total = leftPadding + rightPadding;
            for (let i = 0; i < count; i++) total += itemAt(i).implicitWidth;
            return total + Math.max(0, count - 1) * spacing;
        }
        visible: count > 0
        padding: control.padding
        topPadding: 0
        spacing: control.theme.spacing
        standardButtons: control.standardButtons
        delegate: Button {
            theme: control.theme
            size: control.size
            Keys.onReturnPressed: event => { if (!event.isAutoRepeat) click(); }
            Keys.onEnterPressed: event => { if (!event.isAutoRepeat) click(); }
        }
        background: null
    }
    Controls.Overlay.modal: Rectangle { color: Qt.rgba(0, 0, 0, 0.5) }
    Controls.Overlay.modeless: Rectangle { color: "transparent" }
}
