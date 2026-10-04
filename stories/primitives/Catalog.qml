import QtQml

QtObject {
    readonly property var entries: [
    {
        "id": "ui-button",
        "installName": "button",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add button --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Button { theme: tokens; text: \"Save changes\"; onClicked: console.log(\"saved\") }\n\nSource: registry/quickui/Button.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
                    "destructive",
                    "outline"
                ]
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            },
            {
                "key": "size",
                "label": "Size",
                "type": "select",
                "options": [
                    "sm",
                    "default",
                    "lg"
                ]
            },
            {
                "key": "iconKind",
                "label": "Icon",
                "type": "select",
                "options": [
                    "none",
                    "source",
                    "theme"
                ]
            },
            {
                "key": "iconPosition",
                "label": "Icon position",
                "type": "select",
                "options": [
                    "leading",
                    "trailing"
                ]
            },
            {
                "key": "display",
                "label": "Display",
                "type": "select",
                "options": [
                    "beside",
                    "under",
                    "icon",
                    "text"
                ]
            },
            {
                "key": "loading",
                "label": "Loading",
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
            },
            {
                "name": "Outline",
                "args": {
                    "text": "View details",
                    "variant": "outline"
                }
            },
            {
                "name": "Leading icon",
                "args": {
                    "text": "Add workspace",
                    "iconKind": "source"
                }
            },
            {
                "name": "Trailing icon",
                "args": {
                    "text": "Add workspace",
                    "iconKind": "source",
                    "iconPosition": "trailing"
                }
            },
            {
                "name": "Theme icon",
                "args": {
                    "text": "Add workspace",
                    "iconKind": "theme"
                }
            },
            {
                "name": "Loading",
                "args": {
                    "text": "Save changes",
                    "loading": true
                }
            },
            {
                "name": "Compact",
                "args": {
                    "text": "Save",
                    "size": "sm"
                }
            }
        ]
    },
    {
        "id": "ui-icon-button",
        "installName": "icon-button",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add icon-button --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.IconButton { theme: tokens; text: \"+\"; accessibleLabel: \"Add workspace\" }\n\nSource: registry/quickui/IconButton.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
                    "destructive",
                    "outline"
                ]
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            },
            {
                "key": "size",
                "label": "Size",
                "type": "select",
                "options": [
                    "sm",
                    "default",
                    "lg"
                ]
            },
            {
                "key": "iconKind",
                "label": "Icon",
                "type": "select",
                "options": [
                    "glyph",
                    "source",
                    "theme"
                ]
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
                    "icon": "\u00d7",
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
            },
            {
                "name": "Source icon",
                "args": {
                    "iconKind": "source",
                    "label": "Add workspace"
                }
            },
            {
                "name": "Theme icon",
                "args": {
                    "iconKind": "theme",
                    "label": "Add workspace"
                }
            },
            {
                "name": "Large",
                "args": {
                    "icon": "+",
                    "label": "Add workspace",
                    "size": "lg"
                }
            }
        ]
    },
    {
        "id": "ui-text-field",
        "installName": "text-field",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add text-field --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.TextField { theme: tokens; placeholderText: \"Workspace name\"; Accessible.name: \"Workspace name\" }\n\nSource: registry/quickui/TextField.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
            },
            {
                "key": "invalid",
                "label": "Invalid",
                "type": "boolean"
            },
            {
                "key": "password",
                "label": "Password",
                "type": "boolean"
            },
            {
                "key": "size",
                "label": "Size",
                "type": "select",
                "options": [
                    "sm",
                    "default",
                    "lg"
                ]
            },
            {
                "key": "numeric",
                "label": "Numeric validator",
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
            },
            {
                "name": "Invalid",
                "args": {
                    "text": "Already taken",
                    "invalid": true
                }
            },
            {
                "name": "Password",
                "args": {
                    "text": "secret-example",
                    "password": true,
                    "label": "Password"
                }
            },
            {
                "name": "Compact",
                "args": {
                    "size": "sm"
                }
            },
            {
                "name": "Validated number",
                "args": {
                    "numeric": true,
                    "text": "42",
                    "label": "Workspace number",
                    "placeholder": "1\u2013999"
                }
            }
        ]
    },
    {
        "id": "ui-switch",
        "installName": "switch",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add switch --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Switch { theme: tokens; text: \"Notifications\"; checked: true }\n\nSource: registry/quickui/Switch.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
            },
            {
                "key": "description",
                "label": "Description",
                "type": "text"
            },
            {
                "key": "multiline",
                "label": "Wrap label",
                "type": "boolean"
            },
            {
                "key": "invalid",
                "label": "Invalid",
                "type": "boolean"
            },
            {
                "key": "size",
                "label": "Size",
                "type": "select",
                "options": [
                    "sm",
                    "default",
                    "lg"
                ]
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
            },
            {
                "name": "Description",
                "args": {
                    "text": "Background updates",
                    "description": "Keep this workspace up to date when the panel is closed.",
                    "multiline": true
                }
            },
            {
                "name": "Compact",
                "args": {
                    "text": "Notifications",
                    "size": "sm"
                }
            },
            {
                "name": "Invalid",
                "args": {
                    "text": "Accept the terms",
                    "invalid": true
                }
            }
        ]
    },
    {
        "id": "ui-checkbox",
        "installName": "checkbox",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add checkbox --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.CheckBox { theme: tokens; text: \"Start on login\" }\n\nSource: registry/quickui/CheckBox.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
            },
            {
                "key": "description",
                "label": "Description",
                "type": "text"
            },
            {
                "key": "multiline",
                "label": "Wrap label",
                "type": "boolean"
            },
            {
                "key": "invalid",
                "label": "Invalid",
                "type": "boolean"
            },
            {
                "key": "size",
                "label": "Size",
                "type": "select",
                "options": [
                    "sm",
                    "default",
                    "lg"
                ]
            },
            {
                "key": "tristate",
                "label": "Three states",
                "type": "boolean"
            },
            {
                "key": "partial",
                "label": "Partially checked",
                "type": "boolean"
            },
            {
                "key": "selectAll",
                "label": "Select-all group",
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
            },
            {
                "name": "Description",
                "args": {
                    "text": "Background updates",
                    "description": "Keep this workspace up to date when the panel is closed.",
                    "multiline": true
                }
            },
            {
                "name": "Compact",
                "args": {
                    "text": "Notifications",
                    "size": "sm"
                }
            },
            {
                "name": "Invalid",
                "args": {
                    "text": "Accept the terms",
                    "invalid": true
                }
            },
            {
                "name": "Indeterminate",
                "args": {
                    "text": "Select notifications",
                    "tristate": true,
                    "partial": true
                }
            },
            {
                "name": "Select all",
                "args": {
                    "text": "Select all channels",
                    "selectAll": true
                }
            }
        ]
    },
    {
        "id": "ui-slider",
        "installName": "slider",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add slider --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Slider { theme: tokens; from: 0; to: 100; value: 60; Accessible.name: \"Volume\" }\n\nSource: registry/quickui/Slider.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
            },
            {
                "key": "vertical",
                "label": "Vertical",
                "type": "boolean"
            },
            {
                "key": "rtl",
                "label": "Right to left",
                "type": "boolean"
            },
            {
                "key": "snap",
                "label": "Snap to steps",
                "type": "boolean"
            },
            {
                "key": "releaseOnly",
                "label": "Commit on release",
                "type": "boolean"
            },
            {
                "key": "step",
                "label": "Step",
                "type": "number",
                "min": 1,
                "max": 25,
                "step": 1
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
            },
            {
                "name": "Vertical",
                "args": {
                    "value": 60,
                    "vertical": true
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "value": 60,
                    "rtl": true
                }
            },
            {
                "name": "Snapped steps",
                "args": {
                    "value": 50,
                    "step": 10,
                    "snap": true
                }
            },
            {
                "name": "Release updates",
                "args": {
                    "value": 60,
                    "releaseOnly": true
                }
            }
        ]
    },
    {
        "id": "ui-select",
        "installName": "select",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add select --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Select { theme: tokens; model: [\"Speakers\", \"Headphones\"]; Accessible.name: \"Audio output\" }\n\nSource: registry/quickui/Select.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Select",
        "description": "A themed native choice control with keyboard navigation and a popup.",
        "source": Qt.resolvedUrl("SelectStory.qml"),
        "controls": [
            {
                "key": "index",
                "label": "Selected index",
                "type": "number",
                "min": -1,
                "max": 2,
                "step": 1
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            },
            {
                "key": "placeholder",
                "label": "Placeholder",
                "type": "text"
            },
            {
                "key": "invalid",
                "label": "Invalid",
                "type": "boolean"
            },
            {
                "key": "size",
                "label": "Size",
                "type": "select",
                "options": [
                    "sm",
                    "default",
                    "lg"
                ]
            },
            {
                "key": "editable",
                "label": "Editable",
                "type": "boolean"
            },
            {
                "key": "unavailable",
                "label": "Disable headphones",
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
            },
            {
                "name": "Placeholder",
                "args": {
                    "index": -1,
                    "placeholder": "Choose an output"
                }
            },
            {
                "name": "Invalid",
                "args": {
                    "index": -1,
                    "placeholder": "Choose an output",
                    "invalid": true
                }
            },
            {
                "name": "Unavailable option",
                "args": {
                    "index": 0,
                    "unavailable": true
                }
            },
            {
                "name": "Editable",
                "args": {
                    "index": 0,
                    "editable": true
                }
            }
        ]
    },
    {
        "id": "ui-card",
        "installName": "card",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add card --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Card { theme: tokens; width: 300; Text { text: \"Hello\"; color: tokens.foreground } }\n\nSource: registry/quickui/Card.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
            },
            {
                "key": "size",
                "label": "Size",
                "type": "select",
                "options": [
                    "sm",
                    "default",
                    "lg"
                ]
            },
            {
                "key": "footer",
                "label": "Show footer",
                "type": "boolean"
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
            },
            {
                "name": "Compact sections",
                "args": {
                    "title": "Notifications",
                    "description": "Header, content, and footer share one layout.",
                    "size": "sm",
                    "footer": true
                }
            }
        ]
    },
    {
        "id": "ui-badge",
        "installName": "badge",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add badge --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Badge { theme: tokens; text: \"Connected\"; variant: \"accent\" }\n\nSource: registry/quickui/Badge.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
                    "destructive",
                    "outline"
                ]
            },
            {
                "key": "decoration",
                "label": "Decoration",
                "type": "select",
                "options": [
                    "none",
                    "dot",
                    "icon",
                    "busy"
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
            },
            {
                "name": "Outline",
                "args": {
                    "text": "Metadata",
                    "variant": "outline"
                }
            },
            {
                "name": "Status dot",
                "args": {
                    "text": "Connected",
                    "variant": "accent",
                    "decoration": "dot"
                }
            },
            {
                "name": "With icon",
                "args": {
                    "text": "New workspace",
                    "decoration": "icon"
                }
            },
            {
                "name": "Syncing",
                "args": {
                    "text": "Syncing",
                    "decoration": "busy"
                }
            },
            {
                "name": "Long label",
                "args": {
                    "text": "A long status label remains inside its available space"
                }
            }
        ]
    },
    {
        "id": "ui-separator",
        "installName": "separator",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add separator --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Separator { theme: tokens; width: 280 }\n\nSource: registry/quickui/Separator.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "group": "QuickUI",
        "title": "Separator",
        "description": "A theme-colored divider for horizontal and vertical layouts.",
        "source": Qt.resolvedUrl("SeparatorStory.qml"),
        "controls": [
            {
                "key": "vertical",
                "label": "Vertical",
                "type": "boolean"
            },
            {
                "key": "semantic",
                "label": "Semantic separator",
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
            },
            {
                "name": "Semantic",
                "args": {
                    "semantic": true
                }
            }
        ]
    },
    {
        "id": "ui-field",
        "installName": "field",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add field text-field --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Field { theme: tokens; label: \"Workspace\"; UI.TextField { theme: tokens } }\n\nSource: registry/quickui/Field.qml\nInstalled source is yours to edit.",
        "group": "QuickUI",
        "title": "Field",
        "description": "Persistent labels, descriptions, required indication, and consumer-owned errors.",
        "source": Qt.resolvedUrl("FieldStory.qml"),
        "controls": [
            {
                "key": "label",
                "label": "Label",
                "type": "text"
            },
            {
                "key": "description",
                "label": "Description",
                "type": "text"
            },
            {
                "key": "error",
                "label": "Error",
                "type": "text"
            },
            {
                "key": "required",
                "label": "Required",
                "type": "boolean"
            },
            {
                "key": "largeText",
                "label": "Large text",
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
                "name": "Labeled input",
                "args": {}
            },
            {
                "name": "Validation error",
                "args": {
                    "error": "This workspace name is already in use.",
                    "required": true
                }
            },
            {
                "name": "Large text",
                "args": {
                    "largeText": true,
                    "required": true
                }
            }
        ]
    },
    {
        "id": "ui-range-slider",
        "installName": "range-slider",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add range-slider --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.RangeSlider { theme: tokens; from: 0; to: 100; first.value: 25; second.value: 75; firstAccessibleName: \"Minimum brightness\"; secondAccessibleName: \"Maximum brightness\" }\n\nSource: registry/quickui/RangeSlider.qml\nInstalled source is yours to edit.",
        "group": "QuickUI",
        "title": "Range slider",
        "description": "Two native handles with individual keyboard focus and accessible names.",
        "source": Qt.resolvedUrl("RangeSliderStory.qml"),
        "controls": [
            {
                "key": "minimum",
                "label": "Minimum",
                "type": "number",
                "min": 0,
                "max": 100,
                "step": 5
            },
            {
                "key": "maximum",
                "label": "Maximum",
                "type": "number",
                "min": 0,
                "max": 100,
                "step": 5
            },
            {
                "key": "vertical",
                "label": "Vertical",
                "type": "boolean"
            },
            {
                "key": "rtl",
                "label": "Right to left",
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
                "name": "Brightness range",
                "args": {
                    "minimum": 25,
                    "maximum": 75
                }
            },
            {
                "name": "Vertical",
                "args": {
                    "minimum": 25,
                    "maximum": 75,
                    "vertical": true
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "minimum": 25,
                    "maximum": 75,
                    "rtl": true
                }
            },
            {
                "name": "Coincident handles",
                "args": {
                    "minimum": 50,
                    "maximum": 50
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "minimum": 25,
                    "maximum": 75,
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-theme",
        "installName": "theme",
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add theme --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\n\nSource: registry/quickui/Theme.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
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
            },
            {
                "key": "density",
                "label": "Density",
                "type": "select",
                "options": [
                    "compact",
                    "default",
                    "comfortable"
                ]
            },
            {
                "key": "fontScale",
                "label": "Text scale",
                "type": "number",
                "min": 1,
                "max": 2,
                "step": 0.25
            },
            {
                "key": "subduedSelection",
                "label": "Subdued selection",
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
            },
            {
                "name": "Compact",
                "args": {
                    "density": "compact",
                    "radius": 6
                }
            },
            {
                "name": "Large text",
                "args": {
                    "fontScale": 2,
                    "density": "comfortable",
                    "reduceMotion": true
                }
            },
            {
                "name": "Independent selection",
                "args": {
                    "palette": "Ocean",
                    "subduedSelection": true
                }
            }
        ]
    }
]
}
