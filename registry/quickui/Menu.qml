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

Controls.Menu {
    id: control
    property Theme theme: Theme {}
    property string size: "default"

    // QML styling also works in Quickshell without QApplication/native menus.
    popupType: Controls.Popup.Item
    padding: Math.max(theme.borderWidth, theme.spacing / 2)
    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    palette.window: theme.popup
    palette.windowText: theme.popupForeground
    palette.highlight: theme.selection
    palette.highlightedText: theme.selectionForeground
    delegate: MenuItem { theme: control.theme; size: control.size }

    contentItem: ListView {
        implicitWidth: {
            let widest = 0;
            for (let index = 0; index < control.count; index++) {
                const item = control.itemAt(index);
                if (item) widest = Math.max(widest, item.implicitWidth);
            }
            return widest;
        }
        implicitHeight: contentHeight
        model: control.contentModel
        currentIndex: control.currentIndex
        clip: true
        interactive: contentHeight > height
        Controls.ScrollIndicator.vertical: Controls.ScrollIndicator {}
    }
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.theme.spacing * 2
        color: control.theme.popup
        radius: control.theme.radius
        border.color: control.theme.border
        border.width: control.theme.borderWidth
    }
}
