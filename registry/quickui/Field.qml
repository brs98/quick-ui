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
import QtQuick.Layouts

// One control in a layout, with a persistent label and consumer-owned feedback.
Item {
    id: root
    property Theme theme: Theme {}
    property string label: ""
    property string description: ""
    property string errorText: ""
    property bool requiredIndicator: false
    property bool invalid: errorText.length > 0
    property bool manageAccessibility: true
    property Item control: body.children.length ? body.children[0] : null
    default property alias content: body.data
    implicitWidth: Math.max(200, body.implicitWidth)
    implicitHeight: column.implicitHeight
    Accessible.role: Accessible.Grouping
    Accessible.name: label

    data: [
        ColumnLayout {
            id: column
            width: root.width
            spacing: root.theme.spacing
            Text {
                id: labelText
                objectName: "fieldLabel"
                Layout.fillWidth: true
                visible: root.label.length > 0
                text: root.label + (root.requiredIndicator ? " *" : "")
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: root.theme.foreground
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
                font.weight: Font.Medium
                Accessible.labelFor: root.control
                MouseArea {
                    anchors.fill: parent
                    enabled: root.control !== null && root.control.enabled
                    onClicked: root.control.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
            ColumnLayout {
                id: body
                Layout.fillWidth: true
                spacing: root.theme.spacing
            }
            Text {
                objectName: "fieldDescription"
                Layout.fillWidth: true
                visible: root.description.length > 0
                text: root.description
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: root.theme.mutedForeground
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.smallFontSize
            }
            Text {
                objectName: "fieldError"
                Layout.fillWidth: true
                visible: root.invalid && root.errorText.length > 0
                text: root.errorText
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: root.theme.destructive
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.smallFontSize
            }
        },
        Binding {
            target: root.control
            property: "Accessible.name"
            value: root.label
            when: root.control !== null && root.manageAccessibility && root.label.length > 0
            restoreMode: Binding.RestoreBindingOrValue
        },
        Binding {
            target: root.control
            property: "Accessible.description"
            value: [root.requiredIndicator ? qsTr("Required") : "", root.description,
                    root.invalid ? root.errorText : ""].filter(text => text.length > 0).join(". ")
            when: root.control !== null && root.manageAccessibility
            restoreMode: Binding.RestoreBindingOrValue
        },
        Binding {
            target: root.control
            property: "invalid"
            value: root.invalid
            when: root.control !== null && root.control.hasOwnProperty("invalid")
            restoreMode: Binding.RestoreBindingOrValue
        }
    ]
}
