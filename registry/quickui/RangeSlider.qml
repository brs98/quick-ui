import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.RangeSlider {
    id: control
    property Theme theme: Theme {}
    property string firstAccessibleName: qsTr("Minimum")
    property string secondAccessibleName: qsTr("Maximum")
    padding: theme.spacing
    implicitWidth: horizontal ? 240 : Math.max(theme.controlHeight, theme.handleSize + topPadding + bottomPadding)
    implicitHeight: horizontal ? Math.max(theme.controlHeight, theme.handleSize + topPadding + bottomPadding) : 240
    opacity: enabled ? 1 : theme.disabledOpacity
    Accessible.role: Accessible.Grouping
    function accessibleStep(firstThumb: bool, increase: bool): void {
        if (!enabled) return;
        const node = firstThumb ? first : second;
        const previous = node.value;
        if (increase) node.increase();
        else node.decrease();
        if (node.value !== previous) node.moved();
    }

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        width: control.horizontal ? control.availableWidth : 4
        height: control.horizontal ? 4 : control.availableHeight
        radius: 2
        color: control.theme.border
        Rectangle {
            x: control.horizontal ? Math.min(control.first.visualPosition, control.second.visualPosition) * parent.width : 0
            y: control.horizontal ? 0 : Math.min(control.first.visualPosition, control.second.visualPosition) * parent.height
            width: control.horizontal ? Math.abs(control.second.position - control.first.position) * parent.width : parent.width
            height: control.horizontal ? parent.height : Math.abs(control.second.position - control.first.position) * parent.height
            radius: 2
            color: control.theme.primary
        }
    }

    first.handle: Rectangle {
        id: firstHandle
        property alias value: control.first.value
        readonly property real from: Math.min(control.from, control.to)
        readonly property real to: Math.max(control.from, control.to)
        readonly property real stepSize: control.stepSize
        implicitWidth: control.theme.handleSize
        implicitHeight: implicitWidth
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))
        radius: width / 2
        color: control.first.pressed ? control.theme.primary : control.theme.surface
        border.width: control.theme.borderWidth
        border.color: control.theme.primary
        Accessible.name: control.firstAccessibleName
        Accessible.role: Accessible.Slider
        Accessible.onIncreaseAction: control.accessibleStep(true, true)
        Accessible.onDecreaseAction: control.accessibleStep(true, false)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: width / 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: firstHandle.activeFocus
        }
    }
    second.handle: Rectangle {
        id: secondHandle
        property alias value: control.second.value
        readonly property real from: Math.min(control.from, control.to)
        readonly property real to: Math.max(control.from, control.to)
        readonly property real stepSize: control.stepSize
        implicitWidth: control.theme.handleSize
        implicitHeight: implicitWidth
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
        radius: width / 2
        color: control.second.pressed ? control.theme.primary : control.theme.surface
        border.width: control.theme.borderWidth
        border.color: control.theme.primary
        Accessible.name: control.secondAccessibleName
        Accessible.role: Accessible.Slider
        Accessible.onIncreaseAction: control.accessibleStep(false, true)
        Accessible.onDecreaseAction: control.accessibleStep(false, false)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: width / 2
            color: "transparent"
            border.width: control.theme.focusWidth
            border.color: control.theme.focus
            visible: secondHandle.activeFocus
        }
    }
}
