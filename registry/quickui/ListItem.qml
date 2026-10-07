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
    property string size: "default"
    property string description: ""
    // Selection belongs to the view; highlighted is a separate navigation cursor.
    property bool selected: false
    // Slots supply visual Items with implicitWidth/implicitHeight.
    property Component leading: null
    property Component trailing: null
    readonly property color foregroundColor: selected || highlighted ? theme.selectionForeground : theme.foreground
    readonly property color descriptionColor: selected || highlighted ? theme.selectionForeground : theme.mutedForeground

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.paddingFor(size)
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    implicitWidth: Math.max(200, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(theme.heightFor(size), implicitContentHeight + topPadding + bottomPadding)
    icon.width: theme.handleSize
    icon.height: theme.handleSize
    icon.color: foregroundColor

    Accessible.role: Accessible.ListItem
    Accessible.name: text
    Accessible.description: description
    Accessible.selectable: true
    Accessible.selected: selected
    Accessible.focusable: enabled && focusPolicy !== Qt.NoFocus
    Accessible.onPressAction: control.click()

    contentItem: Item {
        id: content
        // Geometry follows Control.mirrored exactly once, including inherited RTL.
        LayoutMirroring.enabled: false
        clip: true
        readonly property bool showIcon: control.leading === null && control.display !== Controls.AbstractButton.TextOnly
            && (control.icon.name.length > 0 || control.icon.source.toString().length > 0)
        readonly property bool showText: control.display !== Controls.AbstractButton.IconOnly
        readonly property real leadingNaturalWidth: control.leading !== null ? leadingSlot.naturalWidth : showIcon ? graphic.implicitWidth : 0
        readonly property real trailingNaturalWidth: trailingSlot.naturalWidth
        readonly property real leadingWidth: Math.min(width, leadingNaturalWidth)
        readonly property real trailingWidth: Math.min(Math.max(0, width - leadingWidth - (leadingWidth > 0 ? control.spacing : 0)), trailingNaturalWidth)
        readonly property real leadingExtent: leadingWidth > 0 ? leadingWidth + control.spacing : 0
        readonly property real trailingExtent: trailingWidth > 0 ? trailingWidth + control.spacing : 0
        implicitWidth: leadingNaturalWidth + trailingNaturalWidth
            + (leadingNaturalWidth > 0 ? control.spacing : 0) + (trailingNaturalWidth > 0 ? control.spacing : 0)
            + (showText ? Math.max(title.implicitWidth, detail.implicitWidth) : 0)
        implicitHeight: Math.max(labels.implicitHeight, leadingSlot.naturalHeight,
                                showIcon ? graphic.implicitHeight : 0, trailingSlot.naturalHeight)

        Loader {
            id: leadingSlot
            objectName: "listLeading"
            // Null sourceComponent already unloads the slot; keep native active
            // state to avoid re-entrant activation during a component swap.
            sourceComponent: control.leading
            readonly property Item visualItem: item as Item
            readonly property real naturalWidth: visualItem ? visualItem.implicitWidth : 0
            readonly property real naturalHeight: visualItem ? visualItem.implicitHeight : 0
            width: content.leadingWidth
            height: naturalHeight
            x: control.mirrored ? content.width - width : 0
            anchors.verticalCenter: parent.verticalCenter
        }
        IconGraphic {
            id: graphic
            objectName: "listIcon"
            icon: control.icon
            visible: content.showIcon
            x: control.mirrored ? content.width - width : 0
            anchors.verticalCenter: parent.verticalCenter
        }
        Column {
            id: labels
            visible: content.showText
            x: control.mirrored ? content.trailingExtent : content.leadingExtent
            width: Math.max(0, parent.width - content.leadingExtent - content.trailingExtent)
            anchors.verticalCenter: parent.verticalCenter
            spacing: title.visible && detail.visible ? Math.max(2, control.theme.spacing / 2) : 0
            Text {
                id: title
                objectName: "listTitle"
                LayoutMirroring.enabled: false
                width: parent.width
                visible: text.length > 0
                text: control.text
                textFormat: Text.PlainText
                font: control.font
                color: control.foregroundColor
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                elide: Text.ElideRight
                Accessible.ignored: true
            }
            Text {
                id: detail
                objectName: "listDescription"
                LayoutMirroring.enabled: false
                width: parent.width
                visible: text.length > 0
                text: control.description
                textFormat: Text.PlainText
                font.family: control.font.family
                font.pixelSize: control.theme.smallFontSize
                color: control.descriptionColor
                horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
                wrapMode: Text.Wrap
                Accessible.ignored: true
            }
        }
        Loader {
            id: trailingSlot
            objectName: "listTrailing"
            sourceComponent: control.trailing
            readonly property Item visualItem: item as Item
            readonly property real naturalWidth: visualItem ? visualItem.implicitWidth : 0
            readonly property real naturalHeight: visualItem ? visualItem.implicitHeight : 0
            width: content.trailingWidth
            height: naturalHeight
            x: control.mirrored ? 0 : content.width - width
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    background: Rectangle {
        color: control.selected || control.highlighted ? control.theme.selection
            : control.hovered || control.down ? control.theme.surfaceHover : "transparent"
        radius: control.theme.radius
        border.color: control.theme.focus
        border.width: control.visualFocus ? control.theme.focusWidth : 0
        Rectangle {
            objectName: "listFocusRing"
            anchors.fill: parent
            anchors.margins: -control.theme.focusWidth - 2
            radius: parent.radius + control.theme.focusWidth + 2
            color: "transparent"
            border.color: control.theme.focus
            border.width: control.theme.focusWidth
            visible: control.visualFocus
        }
    }
}
