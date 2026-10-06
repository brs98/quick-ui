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

Controls.Button {
    id: control
    property Theme theme: Theme {}
    Accessible.name: text
    property string variant: "primary"
    property string size: "default" // sm, default, lg
    property string iconPosition: "leading" // leading, trailing; respects mirroring
    // Visual progress only. Guard onClicked with !loading to preserve focus,
    // or bind enabled: !loading when the action should become disabled.
    property bool loading: false
    Accessible.description: loading ? qsTr("Loading") : ""

    readonly property color fillColor: variant === "destructive" ? theme.destructive
        : variant === "primary" ? theme.primary
        : (variant === "ghost" || variant === "outline") && !hovered && !down && !checked ? "transparent"
        : hovered || down || checked ? theme.surfaceHover : theme.surface
    readonly property color labelColor: variant === "destructive" ? theme.destructiveForeground
        : variant === "primary" ? theme.primaryForeground : theme.foreground

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    font.weight: Font.Medium
    padding: theme.paddingFor(size)
    verticalPadding: Math.max(4, theme.spacing * (size === "sm" ? 0.75 : size === "lg" ? 1.25 : 1))
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    palette.buttonText: labelColor
    palette.brightText: labelColor
    palette.windowText: labelColor
    palette.highlight: labelColor
    icon.width: Math.round(theme.fontSize * 1.4)
    icon.height: Math.round(theme.fontSize * 1.4)
    icon.color: labelColor
    contentItem: Item {
        id: content
        clip: true
        // Keep the familiar inspection property while rendering only plain text.
        property string text: control.text
        readonly property bool showIcon: control.display !== Controls.Button.TextOnly && (control.icon.name.length > 0 || control.icon.source.toString().length > 0)
        readonly property bool showText: control.display !== Controls.Button.IconOnly && text.length > 0
        readonly property bool stacked: control.display === Controls.Button.TextUnderIcon
        readonly property real gap: showIcon && showText ? control.spacing : 0
        readonly property real iconWidth: showIcon ? graphic.implicitWidth : 0
        readonly property real iconHeight: showIcon ? graphic.implicitHeight : 0
        readonly property real labelWidth: showText ? label.implicitWidth : 0
        readonly property real labelHeight: showText ? label.implicitHeight : 0
        readonly property real usedWidth: Math.min(width, implicitWidth)
        readonly property bool iconAtRight: control.mirrored !== (control.iconPosition === "trailing")
        implicitWidth: stacked ? Math.max(iconWidth, labelWidth) : iconWidth + gap + labelWidth
        implicitHeight: stacked ? iconHeight + gap + labelHeight : Math.max(iconHeight, labelHeight)
        opacity: control.loading ? 0 : 1
        IconGraphic {
            id: graphic
            icon: control.icon
            visible: content.showIcon
            x: content.stacked ? (parent.width - width) / 2
                : (parent.width - content.usedWidth) / 2 + (content.iconAtRight ? content.usedWidth - width : 0)
            y: content.stacked ? (parent.height - content.implicitHeight) / 2 : (parent.height - height) / 2
        }
        Text {
            id: label
            visible: content.showText
            text: content.text
            textFormat: Text.PlainText
            font: control.font
            color: control.labelColor
            width: Math.max(0, content.stacked ? parent.width : content.usedWidth - content.iconWidth - content.gap)
            x: content.stacked ? 0 : (parent.width - content.usedWidth) / 2 + (content.iconAtRight ? 0 : content.iconWidth + content.gap)
            y: content.stacked ? (parent.height - content.implicitHeight) / 2 + content.iconHeight + content.gap : (parent.height - height) / 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
    Text {
        anchors.centerIn: parent
        visible: control.loading
        text: "◌"
        color: control.labelColor
        font.pixelSize: control.font.pixelSize * 1.4
        Accessible.ignored: true
        RotationAnimator on rotation {
            running: control.loading && control.visible && control.theme.motionDuration > 0
            from: 0; to: 360; duration: Math.max(600, control.theme.motionDuration * 8)
            loops: Animation.Infinite
        }
    }

    background: Rectangle {
        implicitWidth: control.theme.heightFor(control.size) * 2
        implicitHeight: control.theme.heightFor(control.size)
        radius: control.theme.radius
        color: control.fillColor
        border.width: control.visualFocus ? control.theme.focusWidth
            : (control.variant === "secondary" || control.variant === "outline") ? control.theme.borderWidth : 0
        border.color: control.visualFocus ? control.theme.focus : control.theme.border

        Rectangle {
            anchors.fill: parent
            anchors.margins: -control.theme.focusWidth - 2
            radius: parent.radius + control.theme.focusWidth + 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: control.visualFocus
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: parent.border.width
            radius: Math.max(0, parent.radius - parent.border.width)
            color: control.labelColor
            opacity: control.down ? 0.14 : control.hovered ? 0.06 : 0
            Behavior on opacity { NumberAnimation { duration: control.theme.motionDuration } }
        }
        Behavior on color { ColorAnimation { duration: control.theme.motionDuration } }
    }
}
