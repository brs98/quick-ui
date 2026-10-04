import QtQml

QtObject {
    readonly property var entries: [
    {
        "id": "ui-button",
        "installName": "button",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add button --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.Button { theme: theme; text: \"Save changes\"; onClicked: console.log(\"saved\") }\n\nSource: registry/quickui/Button.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Button",
        "description": "Native keyboard and pointer behavior with semantic visual variants.",
        "source": Qt.resolvedUrl("ButtonStory.qml"),
        "controls": [
            {
                "key": "text",
                "label": "Label",
                "type": "text"
            },
            {
                "key": "variant",
                "label": "Variant",
                "type": "select",
                "options": [
                    "primary",
                    "secondary",
                    "ghost",
                    "destructive"
                ]
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Primary",
                "args": {
                    "text": "Save changes",
                    "variant": "primary",
                    "disabled": false
                }
            },
            {
                "name": "Secondary",
                "args": {
                    "text": "Save changes",
                    "variant": "secondary",
                    "disabled": false
                }
            },
            {
                "name": "Ghost",
                "args": {
                    "text": "Save changes",
                    "variant": "ghost",
                    "disabled": false
                }
            },
            {
                "name": "Destructive",
                "args": {
                    "text": "Delete workspace",
                    "variant": "destructive",
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Save changes",
                    "variant": "primary",
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-icon-button",
        "installName": "icon-button",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add icon-button --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.IconButton { theme: theme; text: \"+\"; accessibleLabel: \"Add workspace\" }\n\nSource: registry/quickui/IconButton.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Icon button",
        "description": "A compact action with a separate accessible name.",
        "source": Qt.resolvedUrl("IconButtonStory.qml"),
        "controls": [
            {
                "key": "icon",
                "label": "Glyph",
                "type": "text"
            },
            {
                "key": "label",
                "label": "Accessible label",
                "type": "text"
            },
            {
                "key": "variant",
                "label": "Variant",
                "type": "select",
                "options": [
                    "primary",
                    "secondary",
                    "ghost",
                    "destructive"
                ]
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Add",
                "args": {
                    "icon": "+",
                    "label": "Add workspace",
                    "variant": "secondary",
                    "disabled": false
                }
            },
            {
                "name": "Close",
                "args": {
                    "icon": "×",
                    "label": "Close panel",
                    "variant": "ghost",
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "icon": "+",
                    "label": "Add workspace",
                    "variant": "secondary",
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-text-field",
        "installName": "text-field",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add text-field --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.TextField { theme: theme; placeholderText: \"Workspace name\"; Accessible.name: \"Workspace name\" }\n\nSource: registry/quickui/TextField.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Text field",
        "description": "Editable text with selection, native keyboard handling, and focus styling.",
        "source": Qt.resolvedUrl("TextFieldStory.qml"),
        "controls": [
            {
                "key": "text",
                "label": "Text",
                "type": "text"
            },
            {
                "key": "placeholder",
                "label": "Placeholder",
                "type": "text"
            },
            {
                "key": "label",
                "label": "Accessible label",
                "type": "text"
            },
            {
                "key": "readOnly",
                "label": "Read only",
                "type": "boolean"
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Empty",
                "args": {
                    "text": "",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": false,
                    "disabled": false
                }
            },
            {
                "name": "Filled",
                "args": {
                    "text": "Personal workspace",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": false,
                    "disabled": false
                }
            },
            {
                "name": "Read only",
                "args": {
                    "text": "Shared workspace",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": true,
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Personal workspace",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": false,
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-switch",
        "installName": "switch",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add switch --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.Switch { theme: theme; text: \"Notifications\"; checked: true }\n\nSource: registry/quickui/Switch.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Switch",
        "description": "Native toggle behavior. Space activates the focused control.",
        "source": Qt.resolvedUrl("SwitchStory.qml"),
        "controls": [
            {
                "key": "text",
                "label": "Label",
                "type": "text"
            },
            {
                "key": "checked",
                "label": "Checked",
                "type": "boolean"
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Off",
                "args": {
                    "text": "Do not disturb",
                    "checked": false,
                    "disabled": false
                }
            },
            {
                "name": "On",
                "args": {
                    "text": "Do not disturb",
                    "checked": true,
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Do not disturb",
                    "checked": true,
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-checkbox",
        "installName": "checkbox",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add checkbox --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.CheckBox { theme: theme; text: \"Start on login\" }\n\nSource: registry/quickui/CheckBox.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Checkbox",
        "description": "Native toggle behavior. Space activates the focused control.",
        "source": Qt.resolvedUrl("CheckBoxStory.qml"),
        "controls": [
            {
                "key": "text",
                "label": "Label",
                "type": "text"
            },
            {
                "key": "checked",
                "label": "Checked",
                "type": "boolean"
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Off",
                "args": {
                    "text": "Start on login",
                    "checked": false,
                    "disabled": false
                }
            },
            {
                "name": "On",
                "args": {
                    "text": "Start on login",
                    "checked": true,
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Start on login",
                    "checked": true,
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-slider",
        "installName": "slider",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add slider --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.Slider { theme: theme; from: 0; to: 100; value: 60; Accessible.name: \"Volume\" }\n\nSource: registry/quickui/Slider.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Slider",
        "description": "A bounded value control supporting drag, click, and arrow keys.",
        "source": Qt.resolvedUrl("SliderStory.qml"),
        "controls": [
            {
                "key": "value",
                "label": "Value",
                "type": "number",
                "min": 0,
                "max": 100,
                "step": 1
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Listening",
                "args": {
                    "value": 60,
                    "disabled": false
                }
            },
            {
                "name": "Minimum",
                "args": {
                    "value": 0,
                    "disabled": false
                }
            },
            {
                "name": "Maximum",
                "args": {
                    "value": 100,
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "value": 60,
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-select",
        "installName": "select",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add select --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.Select { theme: theme; model: [\"Speakers\", \"Headphones\"]; Accessible.name: \"Audio output\" }\n\nSource: registry/quickui/Select.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Select",
        "description": "A themed native choice control with keyboard navigation and a popup.",
        "source": Qt.resolvedUrl("SelectStory.qml"),
        "controls": [
            {
                "key": "index",
                "label": "Selected index",
                "type": "number",
                "min": 0,
                "max": 2,
                "step": 1
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Speakers",
                "args": {
                    "index": 0,
                    "disabled": false
                }
            },
            {
                "name": "Headphones",
                "args": {
                    "index": 1,
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "index": 0,
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-card",
        "installName": "card",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add card --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.Card { theme: theme; width: 300; Text { text: \"Hello\"; color: theme.foreground } }\n\nSource: registry/quickui/Card.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Card",
        "description": "A padded surface that composes ordinary QML content.",
        "source": Qt.resolvedUrl("CardStory.qml"),
        "controls": [
            {
                "key": "title",
                "label": "Title",
                "type": "text"
            },
            {
                "key": "description",
                "label": "Description",
                "type": "text"
            }
        ],
        "presets": [
            {
                "name": "Welcome",
                "args": {
                    "title": "Your workspace",
                    "description": "Build a shell that feels like yours."
                }
            },
            {
                "name": "Long content",
                "args": {
                    "title": "A place for everything",
                    "description": "Cards resize around their content. Compose labels, controls, and layouts while keeping the same shared theme."
                }
            }
        ]
    },
    {
        "id": "ui-badge",
        "installName": "badge",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add badge --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.Badge { theme: theme; text: \"Connected\"; variant: \"accent\" }\n\nSource: registry/quickui/Badge.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Badge",
        "description": "Compact status text with semantic colors.",
        "source": Qt.resolvedUrl("BadgeStory.qml"),
        "controls": [
            {
                "key": "text",
                "label": "Text",
                "type": "text"
            },
            {
                "key": "variant",
                "label": "Variant",
                "type": "select",
                "options": [
                    "neutral",
                    "accent",
                    "destructive"
                ]
            }
        ],
        "presets": [
            {
                "name": "Neutral",
                "args": {
                    "text": "Draft",
                    "variant": "neutral"
                }
            },
            {
                "name": "Accent",
                "args": {
                    "text": "Connected",
                    "variant": "accent"
                }
            },
            {
                "name": "Destructive",
                "args": {
                    "text": "Offline",
                    "variant": "destructive"
                }
            }
        ]
    },
    {
        "id": "ui-separator",
        "installName": "separator",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add separator --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\nUI.Separator { theme: theme; width: 280 }\n\nSource: registry/quickui/Separator.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Separator",
        "description": "A theme-colored divider for horizontal and vertical layouts.",
        "source": Qt.resolvedUrl("SeparatorStory.qml"),
        "controls": [
            {
                "key": "vertical",
                "label": "Vertical",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Horizontal",
                "args": {
                    "vertical": false
                }
            },
            {
                "name": "Vertical",
                "args": {
                    "vertical": true
                }
            }
        ]
    },
    {
        "id": "ui-theme",
        "installName": "theme",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add theme --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: theme; dark: true; accent: \"#72dce8\" }\n\nSource: registry/quickui/Theme.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Theme playground",
        "description": "One shared Theme object styles every component. Change tokens live.",
        "source": Qt.resolvedUrl("ThemeStory.qml"),
        "controls": [
            {
                "key": "palette",
                "label": "Palette",
                "type": "select",
                "options": [
                    "Lavender",
                    "Ocean",
                    "Rose"
                ]
            },
            {
                "key": "radius",
                "label": "Corner radius",
                "type": "number",
                "min": 0,
                "max": 20,
                "step": 1
            },
            {
                "key": "height",
                "label": "Control height",
                "type": "number",
                "min": 30,
                "max": 48,
                "step": 1
            },
            {
                "key": "reduceMotion",
                "label": "Reduce motion",
                "type": "boolean"
            }
        ],
        "presets": [
            {
                "name": "Lavender",
                "args": {
                    "palette": "Lavender",
                    "radius": 8,
                    "height": 36,
                    "reduceMotion": false
                }
            },
            {
                "name": "Ocean",
                "args": {
                    "palette": "Ocean",
                    "radius": 12,
                    "height": 40,
                    "reduceMotion": false
                }
            },
            {
                "name": "Sharp",
                "args": {
                    "palette": "Rose",
                    "radius": 0,
                    "height": 36,
                    "reduceMotion": true
                }
            }
        ]
    }
]
}
