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

Dialog {
    id: control
    property string description: ""
    property string confirmText: qsTr("Continue")
    property string cancelText: qsTr("Cancel")
    property string variant: "destructive" // destructive, primary
    property bool confirmEnabled: true
    readonly property alias confirmButton: confirmAction
    readonly property alias cancelButton: cancelAction

    closePolicy: Controls.Popup.CloseOnEscape
    height: Math.min(implicitHeight, parent ? Math.max(0, parent.height - margins * 2) : implicitHeight)
    Binding {
        target: control.contentItem.parent
        property: "Accessible.description"
        value: control.description
    }
    onOpened: cancelAction.forceActiveFocus(Qt.TabFocusReason)

    contentItem: Controls.ScrollView {
        implicitWidth: 320
        implicitHeight: message.implicitHeight
        clip: true
        contentWidth: availableWidth
        Text {
            id: message
            width: parent ? control.availableWidth : 0
            text: control.description
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            color: control.theme.popupForeground
            font: control.font
        }
    }
    footer: Item {
        implicitWidth: cancelAction.implicitWidth + confirmAction.implicitWidth + control.theme.spacing + control.padding * 2
        implicitHeight: actions.implicitHeight + control.padding
        Flow {
            id: actions
            x: control.padding
            width: Math.max(0, parent.width - control.padding * 2)
            spacing: control.theme.spacing
            readonly property bool stacked: cancelAction.implicitWidth + confirmAction.implicitWidth + spacing > width

            Button {
                id: cancelAction
                theme: control.theme
                size: control.size
                text: control.cancelText
                variant: "outline"
                implicitWidth: cancelMetrics.advanceWidth + leftPadding + rightPadding
                implicitHeight: Math.max(theme.heightFor(size), cancelLabel.implicitHeight + topPadding + bottomPadding)
                width: actions.stacked ? actions.width : implicitWidth
                TextMetrics { id: cancelMetrics; text: cancelAction.text; font: cancelAction.font }
                contentItem: Text {
                    id: cancelLabel
                    text: cancelAction.text
                    textFormat: Text.PlainText
                    font: cancelAction.font
                    color: cancelAction.labelColor
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: control.reject()
                Keys.onReturnPressed: event => { if (!event.isAutoRepeat) click(); }
                Keys.onEnterPressed: event => { if (!event.isAutoRepeat) click(); }
                KeyNavigation.left: confirmAction
                KeyNavigation.right: confirmAction
            }
            Button {
                id: confirmAction
                theme: control.theme
                size: control.size
                text: control.confirmText
                variant: control.variant
                enabled: control.confirmEnabled
                implicitWidth: confirmMetrics.advanceWidth + leftPadding + rightPadding
                implicitHeight: Math.max(theme.heightFor(size), confirmLabel.implicitHeight + topPadding + bottomPadding)
                width: actions.stacked ? actions.width : implicitWidth
                TextMetrics { id: confirmMetrics; text: confirmAction.text; font: confirmAction.font }
                contentItem: Text {
                    id: confirmLabel
                    text: confirmAction.text
                    textFormat: Text.PlainText
                    font: confirmAction.font
                    color: confirmAction.labelColor
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: control.accept()
                Keys.onReturnPressed: event => { if (!event.isAutoRepeat) click(); }
                Keys.onEnterPressed: event => { if (!event.isAutoRepeat) click(); }
                KeyNavigation.left: cancelAction
                KeyNavigation.right: cancelAction
            }
        }
    }
}
