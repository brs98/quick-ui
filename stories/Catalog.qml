import QtQuick
import "primitives" as Primitives
import "audio" as Audio

QtObject {
    property Primitives.Catalog primitives: Primitives.Catalog {}
    property Audio.Catalog audio: Audio.Catalog {}
    readonly property var entries: primitives.entries.concat(audio.entries, demos)
    readonly property var demos: [
        {
            id: "action-button",
            group: "Example blocks",
            title: "Action button",
            description: "A focused action with three visual tones, keyboard support, and a busy state.",
            source: Qt.resolvedUrl("ButtonStory.qml"),
            controls: [
                { key: "label", label: "Label", type: "text" },
                { key: "tone", label: "Tone", type: "select", options: ["primary", "secondary", "danger"] },
                { key: "disabled", label: "Disabled", type: "boolean" },
                { key: "busy", label: "Busy", type: "boolean" }
            ],
            presets: [
                { name: "Primary", args: { label: "Create workspace", tone: "primary", disabled: false, busy: false } },
                { name: "Secondary", args: { label: "View details", tone: "secondary", disabled: false, busy: false } },
                { name: "Danger", args: { label: "Delete workspace", tone: "danger", disabled: false, busy: false } },
                { name: "Loading", args: { label: "Create workspace", tone: "primary", disabled: false, busy: true } }
            ]
        },
        {
            id: "volume-card",
            group: "Example blocks",
            title: "Volume card",
            description: "An interactive output control with local preview state. Drag the slider or toggle mute to inspect emitted events.",
            source: Qt.resolvedUrl("VolumeStory.qml"),
            controls: [
                { key: "deviceName", label: "Device name", type: "text" },
                { key: "volume", label: "Volume", type: "number", min: 0, max: 100, step: 1 },
                { key: "muted", label: "Muted", type: "boolean" }
            ],
            presets: [
                { name: "Listening", args: { deviceName: "Studio speakers", volume: 64, muted: false } },
                { name: "Quiet hours", args: { deviceName: "Wireless headphones", volume: 22, muted: false } },
                { name: "Muted", args: { deviceName: "Studio speakers", volume: 64, muted: true } },
                { name: "Maximum", args: { deviceName: "Living room audio", volume: 100, muted: false } }
            ]
        },
        {
            id: "notification-card",
            group: "Example blocks",
            title: "Notification card",
            description: "A desktop notification with optional action, severity styling, and dismiss events. The preview stays visible after dismissal.",
            source: Qt.resolvedUrl("NotificationStory.qml"),
            controls: [
                { key: "title", label: "Title", type: "text" },
                { key: "message", label: "Message", type: "text" },
                { key: "sourceName", label: "Source", type: "text" },
                { key: "actionLabel", label: "Action label", type: "text" },
                { key: "severity", label: "Severity", type: "select", options: ["info", "success", "warning"] },
                { key: "showAction", label: "Show action", type: "boolean" }
            ],
            presets: [
                { name: "Welcome", args: { title: "Your workspace is ready", message: "Everything is right where you left it. Pick up where you paused.", sourceName: "QUICKBOOK", actionLabel: "Open workspace", severity: "info", showAction: true } },
                { name: "Success", args: { title: "All changes saved", message: "Your settings are synced and ready for your next session.", sourceName: "SYSTEM", actionLabel: "View changes", severity: "success", showAction: true } },
                { name: "Warning", args: { title: "Running low on battery", message: "Connect a charger to keep your workspace running. You have about 20 minutes left.", sourceName: "POWER", actionLabel: "Power settings", severity: "warning", showAction: true } },
                { name: "Quiet", args: { title: "Focus time", message: "Notifications are paused for the next 30 minutes.", sourceName: "FOCUS", actionLabel: "Open", severity: "info", showAction: false } }
            ]
        }
    ]
}
