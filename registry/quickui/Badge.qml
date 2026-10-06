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

Controls.Label {
    id: control
    property Theme theme: Theme {}
    Accessible.name: text
    property string variant: "neutral"
    property alias icon: graphic.icon
    property bool statusDot: false
    property bool busy: false
    readonly property bool hasGraphic: statusDot || busy || icon.name.length > 0 || icon.source.toString().length > 0
    readonly property bool leadingAtRight: LayoutMirroring.enabled
    readonly property real graphicSize: Math.max(12, theme.smallFontSize)
    readonly property real graphicExtent: statusDot || busy ? graphicSize : graphic.implicitWidth
    readonly property real graphicPadding: hasGraphic ? graphicExtent + theme.spacing / 2 : 0
    readonly property real graphicHeight: hasGraphic ? (statusDot || busy ? graphicSize : graphic.implicitHeight) : 0
    textFormat: Text.PlainText
    elide: Text.ElideRight
    maximumLineCount: 1
    leftPadding: theme.spacing + (leadingAtRight ? 0 : graphicPadding)
    rightPadding: theme.spacing + (leadingAtRight ? graphicPadding : 0)
    topPadding: Math.max(3, (graphicHeight - contentHeight) / 2 + 3)
    bottomPadding: Math.max(3, (graphicHeight - contentHeight) / 2 + 3)
    font.family: theme.fontFamily
    font.pixelSize: theme.smallFontSize
    font.weight: Font.DemiBold
    color: variant === "accent" ? theme.primaryForeground
        : variant === "destructive" ? theme.destructiveForeground : theme.foreground
    opacity: enabled ? 1 : theme.disabledOpacity
    IconGraphic {
        id: graphic
        visible: control.hasGraphic && !control.statusDot && !control.busy
        x: control.leadingAtRight ? control.width - control.theme.spacing - width : control.theme.spacing
        y: (control.height - height) / 2
        icon.width: control.graphicSize
        icon.height: control.graphicSize
        icon.color: control.color
    }
    Rectangle {
        visible: control.statusDot && !control.busy
        width: control.graphicSize / 2
        height: width
        radius: width / 2
        x: (control.leadingAtRight ? control.width - control.theme.spacing - control.graphicSize : control.theme.spacing) + (control.graphicSize - width) / 2
        y: (control.height - height) / 2
        color: control.color
        Accessible.ignored: true
    }
    Text {
        visible: control.busy
        text: "◌"
        textFormat: Text.PlainText
        width: control.graphicSize
        x: control.leadingAtRight ? control.width - control.theme.spacing - width : control.theme.spacing
        y: (control.height - height) / 2
        horizontalAlignment: Text.AlignHCenter
        color: control.color
        font.pixelSize: control.graphicSize
        Accessible.ignored: true
        RotationAnimator on rotation {
            running: control.busy && control.visible && control.theme.motionDuration > 0
            from: 0; to: 360; duration: Math.max(600, control.theme.motionDuration * 8)
            loops: Animation.Infinite
        }
    }
    background: Rectangle {
        radius: height / 2
        color: control.variant === "accent" ? control.theme.primary
            : control.variant === "destructive" ? control.theme.destructive
            : control.variant === "outline" ? "transparent" : control.theme.surfaceHover
        border.width: control.variant === "outline" ? control.theme.borderWidth : 0
        border.color: control.theme.border
    }
}
