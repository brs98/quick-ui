pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Controls
import "../registry/quickui" as UI

Item {
    id: root
    property UI.Theme theme: UI.Theme {}
    property string savedName: "Studio workspace"
    property bool notifications: true
    property bool syncEnabled: false
    property int selectedWorkspace: 0
    property real outputVolume: 0.65
    property bool outputMuted: false
    property string feedback: "Changes stay in this preview."
    readonly property bool twoColumns: width >= 680
    implicitWidth: 720
    implicitHeight: columns.implicitHeight

    function closePopups() {
        moreMenu.close(); confirmation.close(); workspaceType.popup.close();
    }
    function resetPreview() {
        closePopups();
        savedName = "Studio workspace";
        nameInput.text = savedName;
        notifications = true; syncEnabled = false;
        selectedWorkspace = 0; workspaceType.currentIndex = 0;
        outputVolume = 0.65; outputMuted = false;
        feedback = "Changes stay in this preview.";
    }
    onVisibleChanged: if (!visible) closePopups()

    component Heading: Text {
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: root.theme.cardForeground
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize * 1.2
        font.weight: Font.DemiBold
    }
    component Note: Text {
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: root.theme.mutedForeground
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.smallFontSize
    }

    GridLayout {
        id: columns
        width: root.width
        columns: root.twoColumns ? 2 : 1
        columnSpacing: root.theme.spacing * 2
        rowSpacing: root.theme.spacing * 2
        UI.Card {
            id: formCard
            objectName: "galleryFormCard"
            theme: root.theme
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            contentItem: Column {
                spacing: root.theme.spacing * 2
                Heading { width: parent.width; text: "Make it yours" }
                Note { width: parent.width; text: "A familiar settings form, styled with your preset." }
                UI.Field {
                    objectName: "galleryNameField"
                    width: parent.width
                    theme: root.theme
                    label: "Workspace name"
                    UI.TextField {
                        id: nameInput
                        objectName: "galleryNameInput"
                        theme: root.theme
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: "Studio workspace"
                        placeholderText: "Name your workspace"
                    }
                }
                UI.Field {
                    objectName: "galleryTypeField"
                    width: parent.width
                    theme: root.theme
                    label: "Workspace type"
                    UI.Select {
                        id: workspaceType
                        objectName: "galleryTypeSelect"
                        theme: root.theme
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        model: ["Personal", "Shared", "Archive"]
                    }
                }
                UI.Switch {
                    objectName: "galleryNotifications"
                    width: parent.width
                    theme: root.theme
                    text: "Notifications"
                    checked: root.notifications
                    onToggled: root.notifications = checked
                }
                UI.CheckBox {
                    objectName: "gallerySync"
                    width: parent.width
                    theme: root.theme
                    text: "Sync preferences"
                    checked: root.syncEnabled
                    onToggled: root.syncEnabled = checked
                }
                UI.Separator { width: parent.width; theme: root.theme }
                Flow {
                    width: parent.width
                    spacing: root.theme.spacing
                    UI.Button {
                        objectName: "gallerySave"
                        theme: root.theme
                        text: "Save changes"
                        width: Math.min(implicitWidth, parent.width)
                        enabled: nameInput.text.trim().length > 0
                        onClicked: {
                            root.savedName = nameInput.text.trim();
                            root.feedback = "Saved “" + root.savedName + "” in this preview.";
                        }
                    }
                    UI.Button {
                        objectName: "galleryUnavailable"
                        theme: root.theme
                        text: "Publish"
                        width: Math.min(implicitWidth, parent.width)
                        variant: "outline"
                        enabled: false
                    }
                }
                Note { objectName: "galleryFeedback"; width: parent.width; text: root.feedback }
            }
        }
        Column {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: root.theme.spacing * 2
            UI.Card {
                id: workspaceCard
                objectName: "galleryWorkspaceCard"
                width: parent.width
                theme: root.theme
                contentItem: Column {
                    spacing: root.theme.spacing
                    Heading { width: parent.width; text: "Your workspaces" }
                    Flow {
                        width: parent.width
                        spacing: root.theme.spacing
                        UI.Badge { objectName: "galleryActiveBadge"; theme: root.theme; text: "Active"; variant: "accent"; statusDot: true; width: Math.min(implicitWidth, parent.width) }
                        UI.Badge { objectName: "galleryCountBadge"; theme: root.theme; text: "2 workspaces"; width: Math.min(implicitWidth, parent.width) }
                    }
                    UI.ListItem {
                        objectName: "galleryStudioRow"
                        width: parent.width
                        theme: root.theme
                        text: root.savedName
                        description: "Daily work and creative projects"
                        selected: root.selectedWorkspace === 0
                        onClicked: root.selectedWorkspace = 0
                    }
                    UI.ListItem {
                        objectName: "galleryArchiveRow"
                        width: parent.width
                        theme: root.theme
                        text: "Weekend ideas"
                        description: "A little room to experiment"
                        selected: root.selectedWorkspace === 1
                        onClicked: root.selectedWorkspace = 1
                    }
                    Flow {
                        width: parent.width
                        spacing: root.theme.spacing
                        UI.Button {
                            id: menuTrigger
                            objectName: "galleryMenuTrigger"
                            theme: root.theme
                            text: "More actions"
                            variant: "outline"
                            width: Math.min(implicitWidth, parent.width)
                            onClicked: moreMenu.open()
                        }
                        UI.Button {
                            objectName: "galleryDialogTrigger"
                            theme: root.theme
                            text: "Remove…"
                            variant: "ghost"
                            width: Math.min(implicitWidth, parent.width)
                            onClicked: confirmation.open()
                        }
                    }
                }
            }
            UI.Card {
                objectName: "galleryAudioCard"
                width: parent.width
                theme: root.theme
                contentItem: Column {
                    spacing: root.theme.spacing
                    Heading { width: parent.width; text: "Sound check" }
                    Note { width: parent.width; text: "Preview controls without changing system audio." }
                    UI.VolumeControl {
                        objectName: "galleryVolume"
                        width: parent.width
                        theme: root.theme
                        title: "Studio speakers"
                        glyph: "♪"
                        value: root.outputVolume
                        muted: root.outputMuted
                        onVolumeRequested: value => root.outputVolume = value
                        onMuteRequested: root.outputMuted = !root.outputMuted
                    }
                }
            }
        }
    }
    UI.Menu {
        id: moreMenu
        objectName: "galleryMenu"
        parent: menuTrigger
        y: menuTrigger.height
        theme: root.theme
        UI.MenuItem { objectName: "galleryDuplicate"; theme: root.theme; text: "Duplicate workspace"; onTriggered: root.feedback = "Duplicate requested in this preview." }
        UI.MenuSeparator { theme: root.theme }
        UI.MenuItem { theme: root.theme; text: "Share workspace"; enabled: false }
    }
    UI.AlertDialog {
        id: confirmation
        objectName: "galleryDialog"
        parent: Controls.Overlay.overlay
        theme: root.theme
        title: "Remove workspace?"
        description: "This is a preview. Confirming records a local message; no workspace or file is removed."
        confirmText: "Remove"
        onAccepted: root.feedback = "Removal requested in this preview."
        onRejected: root.feedback = "Workspace kept."
    }
}
