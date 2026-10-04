import QtQml

QtObject {
    readonly property var entries: [
    {
        "id": "audio-mixer",
        "installName": "audio-mixer",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add audio-mixer --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.AudioMixer {\n    theme: tokens; width: 380; height: 520\n    hasOutput: true; outputVolume: 0.6\n    outputs: [{id: \"speakers\", label: \"Speakers\", glyph: \"\u266b\", current: true}]\n    onOutputVolumeRequested: value => console.log(\"Set output volume\", value)\n    onOutputSelected: id => console.log(\"Select output\", id)\n}\n\nSource: registry/quickui/AudioMixer.qml\nSignals request changes; your adapter owns service state.",
        "group": "Audio blocks",
        "title": "Audio mixer",
        "description": "A service-free mixer with device selection, channel controls, app streams, and optional shell-style navigation.",
        "source": Qt.resolvedUrl("AudioMixerStory.qml"),
        "controls": [
            {
                "key": "scenario",
                "label": "Scenario",
                "type": "select",
                "options": [
                    "Desktop",
                    "Output only",
                    "No devices",
                    "Long labels",
                    "Amplified streams",
                    "No default input"
                ]
            },
            {
                "key": "outputVolume",
                "label": "Output volume",
                "type": "number",
                "min": 0,
                "max": 1,
                "step": 0.05
            },
            {
                "key": "inputVolume",
                "label": "Input volume",
                "type": "number",
                "min": 0,
                "max": 1,
                "step": 0.05
            },
            {
                "key": "peak",
                "label": "Microphone peak",
                "type": "number",
                "min": 0,
                "max": 1,
                "step": 0.05
            },
            {
                "key": "muted",
                "label": "Muted",
                "type": "boolean"
            },
            {
                "key": "panelNavigation",
                "label": "Shell keyboard navigation",
                "type": "boolean"
            },
            {
                "key": "rtl",
                "label": "Right to left",
                "type": "boolean"
            },
            {
                "key": "fontScale",
                "label": "Text scale",
                "type": "number",
                "min": 1,
                "max": 3,
                "step": 0.5
            }
        ],
        "presets": [
            {
                "name": "Desktop",
                "args": {
                    "scenario": "Desktop",
                    "outputVolume": 0.6,
                    "inputVolume": 0.75,
                    "peak": 0.35,
                    "muted": false,
                    "panelNavigation": false
                }
            },
            {
                "name": "Muted",
                "args": {
                    "scenario": "Desktop",
                    "outputVolume": 0.6,
                    "inputVolume": 0.75,
                    "peak": 0,
                    "muted": true,
                    "panelNavigation": false
                }
            },
            {
                "name": "No devices",
                "args": {
                    "scenario": "No devices",
                    "outputVolume": 0,
                    "inputVolume": 0,
                    "peak": 0,
                    "muted": false,
                    "panelNavigation": false
                }
            },
            {
                "name": "Output only",
                "args": {
                    "scenario": "Output only",
                    "outputVolume": 0.5,
                    "inputVolume": 0,
                    "peak": 0,
                    "muted": false,
                    "panelNavigation": false
                }
            },
            {
                "name": "Long labels",
                "args": {
                    "scenario": "Long labels",
                    "outputVolume": 0.6,
                    "inputVolume": 0.75,
                    "peak": 0.35,
                    "muted": false,
                    "panelNavigation": false
                }
            },
            {
                "name": "Amplified streams",
                "args": {
                    "scenario": "Amplified streams",
                    "outputVolume": 0.6,
                    "inputVolume": 0.75,
                    "peak": 0.35,
                    "muted": false,
                    "panelNavigation": false
                }
            },
            {
                "name": "Shell navigation",
                "args": {
                    "scenario": "Desktop",
                    "outputVolume": 0.6,
                    "inputVolume": 0.75,
                    "peak": 0.35,
                    "muted": false,
                    "panelNavigation": true
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "rtl": true
                }
            },
            {
                "name": "Large text",
                "args": {
                    "fontScale": 3
                }
            },
            {
                "name": "Choose input",
                "args": {
                    "scenario": "No default input"
                }
            }
        ]
    },
    {
        "id": "ui-volume-control",
        "installName": "volume-control",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add volume-control --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.VolumeControl { theme: tokens; width: 340; title: \"Output\"; value: 0.6; onVolumeRequested: value => console.log(value); onMuteRequested: console.log(\"toggle mute\") }\n\nSource: registry/quickui/VolumeControl.qml\nSignals request changes; your adapter owns service state.",
        "group": "Audio blocks",
        "title": "Volume control",
        "description": "Controlled mute and volume requests, including microphone metering and amplified app streams.",
        "source": Qt.resolvedUrl("VolumeControlStory.qml"),
        "controls": [
            {
                "key": "title",
                "label": "Title",
                "type": "text"
            },
            {
                "key": "value",
                "label": "Volume",
                "type": "number",
                "min": 0,
                "max": 1.5,
                "step": 0.05
            },
            {
                "key": "maximum",
                "label": "Maximum",
                "type": "number",
                "min": 1,
                "max": 1.5,
                "step": 0.5
            },
            {
                "key": "muted",
                "label": "Muted",
                "type": "boolean"
            },
            {
                "key": "available",
                "label": "Available",
                "type": "boolean"
            },
            {
                "key": "showMeter",
                "label": "Show meter",
                "type": "boolean"
            },
            {
                "key": "peak",
                "label": "Peak",
                "type": "number",
                "min": 0,
                "max": 1,
                "step": 0.05
            },
            {
                "key": "rtl",
                "label": "Right to left",
                "type": "boolean"
            },
            {
                "key": "fontScale",
                "label": "Text scale",
                "type": "number",
                "min": 1,
                "max": 3,
                "step": 0.5
            }
        ],
        "presets": [
            {
                "name": "Output",
                "args": {
                    "title": "Output",
                    "value": 0.6,
                    "maximum": 1,
                    "muted": false,
                    "available": true,
                    "showMeter": false,
                    "peak": 0
                }
            },
            {
                "name": "Microphone",
                "args": {
                    "title": "Microphone",
                    "value": 0.75,
                    "maximum": 1,
                    "muted": false,
                    "available": true,
                    "showMeter": true,
                    "peak": 0.4
                }
            },
            {
                "name": "Muted",
                "args": {
                    "title": "Output",
                    "value": 0.6,
                    "maximum": 1,
                    "muted": true,
                    "available": true,
                    "showMeter": false,
                    "peak": 0
                }
            },
            {
                "name": "Unavailable",
                "args": {
                    "title": "Output",
                    "value": 0,
                    "maximum": 1,
                    "muted": false,
                    "available": false,
                    "showMeter": false,
                    "peak": 0
                }
            },
            {
                "name": "Amplified stream",
                "args": {
                    "title": "Music player",
                    "value": 1.3,
                    "maximum": 1.5,
                    "muted": false,
                    "available": true,
                    "showMeter": false,
                    "peak": 0
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "rtl": true
                }
            },
            {
                "name": "Large text",
                "args": {
                    "fontScale": 3
                }
            }
        ]
    },
    {
        "id": "ui-device-item",
        "installName": "device-item",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add device-item --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.DeviceItem { theme: tokens; width: 340; text: \"Speakers\"; glyph: \"\u266b\"; current: true; onClicked: console.log(\"Select speakers\") }\n\nSource: registry/quickui/DeviceItem.qml\nSignals request changes; your adapter owns service state.",
        "group": "QuickUI",
        "title": "Device item",
        "description": "A keyboard-accessible device choice with independent current and focused states.",
        "source": Qt.resolvedUrl("DeviceItemStory.qml"),
        "controls": [
            {
                "key": "text",
                "label": "Label",
                "type": "text"
            },
            {
                "key": "glyph",
                "label": "Glyph",
                "type": "text"
            },
            {
                "key": "current",
                "label": "Current device",
                "type": "boolean"
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            },
            {
                "key": "rtl",
                "label": "Right to left",
                "type": "boolean"
            },
            {
                "key": "fontScale",
                "label": "Text scale",
                "type": "number",
                "min": 1,
                "max": 3,
                "step": 0.5
            },
            {
                "key": "description",
                "label": "Description",
                "type": "text"
            },
            {
                "key": "selectionList",
                "label": "Exclusive selection",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Available",
                "args": {
                    "text": "Headphones",
                    "glyph": "\u266a",
                    "current": false,
                    "disabled": false
                }
            },
            {
                "name": "Current",
                "args": {
                    "text": "Speakers",
                    "glyph": "\u266b",
                    "current": true,
                    "disabled": false
                }
            },
            {
                "name": "Long label",
                "args": {
                    "text": "Studio monitor speakers connected through the external USB audio interface",
                    "glyph": "\u266b",
                    "current": true,
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Disconnected headset",
                    "glyph": "\u266a",
                    "current": false,
                    "disabled": true
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "rtl": true
                }
            },
            {
                "name": "Large text",
                "args": {
                    "fontScale": 3
                }
            },
            {
                "name": "Device details",
                "args": {
                    "label": "USB Audio",
                    "description": "USB-C dock \u00b7 stereo output"
                }
            },
            {
                "name": "Exclusive selection",
                "args": {
                    "selectionList": true
                }
            }
        ]
    },
    {
        "id": "ui-level-meter",
        "installName": "level-meter",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add level-meter --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.LevelMeter { theme: tokens; width: 340; value: 0.35 }\n\nSource: registry/quickui/LevelMeter.qml\nSignals request changes; your adapter owns service state.",
        "group": "QuickUI",
        "title": "Level meter",
        "description": "A bounded display for audio peaks, with muted state and theme motion.",
        "source": Qt.resolvedUrl("LevelMeterStory.qml"),
        "controls": [
            {
                "key": "value",
                "label": "Peak",
                "type": "number",
                "min": 0,
                "max": 1,
                "step": 0.05
            },
            {
                "key": "muted",
                "label": "Muted",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Active",
                "args": {
                    "value": 0.35,
                    "muted": false
                }
            },
            {
                "name": "Silent",
                "args": {
                    "value": 0,
                    "muted": false
                }
            },
            {
                "name": "Full scale",
                "args": {
                    "value": 1,
                    "muted": false
                }
            },
            {
                "name": "Muted",
                "args": {
                    "value": 0.35,
                    "muted": true
                }
            },
            {
                "name": "Low level",
                "args": {
                    "value": 0.01
                }
            },
            {
                "name": "Clamped high",
                "args": {
                    "value": 2
                }
            },
            {
                "name": "Clamped low",
                "args": {
                    "value": -1
                }
            }
        ]
    },
    {
        "id": "ui-tooltip",
        "installName": "tooltip",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add tooltip --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Button {\n    id: trigger; theme: tokens; text: \"Mute\"\n    UI.ToolTip { theme: tokens; text: \"Mute output\"; visible: trigger.hovered || trigger.activeFocus }\n}\n\nSource: registry/quickui/ToolTip.qml\nSignals request changes; your adapter owns service state.",
        "group": "QuickUI",
        "title": "Tooltip",
        "description": "A themed native tooltip; show it from hover or keyboard focus.",
        "source": Qt.resolvedUrl("ToolTipStory.qml"),
        "controls": [
            {
                "key": "text",
                "label": "Text",
                "type": "text"
            },
            {
                "key": "show",
                "label": "Pin preview",
                "type": "boolean"
            },
            {
                "key": "placement",
                "label": "Placement",
                "type": "select",
                "options": [
                    "top",
                    "bottom"
                ]
            },
            {
                "key": "maximumWidth",
                "label": "Maximum width",
                "type": "number",
                "min": 100,
                "max": 400,
                "step": 20
            }
        ],
        "presets": [
            {
                "name": "Short",
                "args": {
                    "text": "Mute output",
                    "show": false
                }
            },
            {
                "name": "Long label",
                "args": {
                    "text": "This control adjusts the selected output device. Right-click to toggle mute.",
                    "show": false
                }
            },
            {
                "name": "Pinned preview",
                "args": {
                    "text": "Mute output",
                    "show": true
                }
            },
            {
                "name": "Narrow above",
                "args": {
                    "text": "Supplemental information wraps to a readable width.",
                    "placement": "top",
                    "maximumWidth": 160
                }
            }
        ]
    }
]
}
