import QtQuick
import QtQuick.Controls.Basic as Controls

Controls.MenuItem {
    id: control
    property Theme theme: Theme {}
    property string size: "default"
    property string variant: "default" // default, destructive
    property string shortcutText: "" // Display only; use Action.shortcut to bind a shortcut.
    property bool hasSubmenu: subMenu !== null // May also describe a host-managed submenu.
    property string indicatorType: "auto" // auto, check, radio; auto uses autoExclusive.
    property bool partiallyChecked: false // Presentation only; checked/checkable stay native.
    readonly property bool radioIndicator: indicatorType === "radio" || (indicatorType === "auto" && autoExclusive)
    readonly property bool hot: highlighted || hovered || down
    readonly property color foregroundColor: hot ? (variant === "destructive" ? theme.destructiveForeground : theme.selectionForeground)
        : variant === "destructive" ? theme.destructive : theme.popupForeground

    font.family: theme.fontFamily
    font.pixelSize: theme.fontSize
    padding: theme.paddingFor(size)
    verticalPadding: Math.max(4, theme.spacing / 2)
    spacing: theme.spacing
    hoverEnabled: true
    opacity: enabled ? 1 : theme.disabledOpacity
    icon.width: theme.handleSize
    icon.height: theme.handleSize
    icon.color: foregroundColor
    implicitWidth: Math.max(200, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(theme.heightFor(size), implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    indicator: Item {
        objectName: "menuCheckIndicator"
        implicitWidth: control.theme.handleSize
        implicitHeight: implicitWidth
        x: control.mirrored ? control.width - width - control.rightPadding : control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        visible: control.checkable && (control.checked || control.partiallyChecked)
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * (control.partiallyChecked ? 0.6 : 0.4)
            height: control.partiallyChecked ? Math.max(2, parent.height * 0.1) : width
            radius: control.partiallyChecked ? 0 : width / 2
            color: control.foregroundColor
            visible: control.partiallyChecked || control.radioIndicator
        }
        Item {
            anchors.centerIn: parent
            width: parent.width * 0.55
            height: parent.height * 0.35
            rotation: -45
            visible: !control.partiallyChecked && !control.radioIndicator
            Rectangle { width: 2; height: parent.height; color: control.foregroundColor }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: control.foregroundColor }
        }
    }
    arrow: Text {
        objectName: "menuSubmenuArrow"
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        text: control.mirrored ? "‹" : "›"
        font: control.font
        color: control.foregroundColor
        visible: control.hasSubmenu
        Accessible.ignored: true
    }
    contentItem: Item {
        id: content
        clip: true
        readonly property bool showIcon: control.display !== Controls.AbstractButton.TextOnly
            && (control.icon.name.length > 0 || control.icon.source.toString().length > 0)
        readonly property bool showText: control.display !== Controls.AbstractButton.IconOnly
        readonly property real leading: control.theme.handleSize + control.spacing
        readonly property real iconExtent: showIcon ? graphic.implicitWidth + control.spacing : 0
        readonly property real arrowExtent: control.hasSubmenu ? control.arrow.implicitWidth + control.spacing : 0
        readonly property real shortcutExtent: control.shortcutText.length > 0 ? shortcut.implicitWidth + control.spacing * 2 : 0
        implicitWidth: leading + iconExtent + (showText ? label.implicitWidth : 0) + shortcutExtent + arrowExtent
        implicitHeight: Math.max(label.implicitHeight, showIcon ? graphic.implicitHeight : 0, shortcut.implicitHeight)
        IconGraphic {
            id: graphic
            objectName: "menuIcon"
            icon: control.icon
            visible: content.showIcon
            x: control.mirrored ? parent.width - content.leading - width : content.leading
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: label
            objectName: "menuLabel"
            // Alignment is already computed from the native mirrored property.
            LayoutMirroring.enabled: false
            text: control.text
            textFormat: Text.PlainText
            font: control.font
            color: control.foregroundColor
            visible: content.showText
            x: control.mirrored ? content.arrowExtent + content.shortcutExtent : content.leading + content.iconExtent
            width: Math.max(0, parent.width - content.leading - content.iconExtent - content.arrowExtent - content.shortcutExtent)
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
            elide: Text.ElideRight
        }
        Text {
            id: shortcut
            objectName: "menuShortcut"
            text: control.shortcutText
            textFormat: Text.PlainText
            font: control.font
            color: control.hot ? control.foregroundColor : control.theme.mutedForeground
            visible: text.length > 0
            x: control.mirrored ? content.arrowExtent : parent.width - content.arrowExtent - width
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    background: Rectangle {
        color: control.hot ? (control.variant === "destructive" ? control.theme.destructive : control.theme.selection) : "transparent"
        radius: control.theme.radiusSmall
        border.color: control.theme.focus
        border.width: control.visualFocus ? control.theme.focusWidth : 0
    }
}
