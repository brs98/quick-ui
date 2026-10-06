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

Item {
    id: root
    property Theme theme: Theme {}
    property real value: 0
    property bool muted: false
    readonly property real boundedValue: Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0
    implicitWidth: 160
    implicitHeight: 6
    // Keep the public name/description customization point while exposing only
    // the bounded child value to Qt's numeric accessibility interface.
    Accessible.ignored: true
    Accessible.name: qsTr("Audio level")
    Accessible.description: muted ? qsTr("Muted") : Math.round(boundedValue * 100) + "%"
    Item {
        objectName: "levelMeterAccessible"
        anchors.fill: parent
        readonly property real value: root.boundedValue
        readonly property real minimumValue: 0
        readonly property real maximumValue: 1
        Accessible.role: Accessible.ProgressBar
        Accessible.name: root.Accessible.name
        Accessible.description: root.Accessible.description
    }
    Rectangle {
        id: track
        anchors.fill: parent
        color: root.theme.border
        radius: height / 2
        // Reveal part of a full-sized rounded pill. A narrow independent pill
        // has different corner geometry and paints outside the track silhouette.
        Item {
            width: parent.width * root.boundedValue
            height: parent.height
            clip: true
            Rectangle {
                width: track.width
                height: track.height
                radius: track.radius
                color: root.muted ? root.theme.mutedForeground : root.theme.accent
            }
        }
    }
}
