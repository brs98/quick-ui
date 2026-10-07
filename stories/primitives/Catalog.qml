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
                    "disabled": false,
                    "size": "default",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Secondary",
                "args": {
                    "text": "Save changes",
                    "variant": "secondary",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Ghost",
                "args": {
                    "text": "Save changes",
                    "variant": "ghost",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Destructive",
                "args": {
                    "text": "Delete workspace",
                    "variant": "destructive",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Save changes",
                    "variant": "primary",
                    "disabled": true,
                    "size": "default",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Outline",
                "args": {
                    "text": "View details",
                    "variant": "outline",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Leading icon",
                "args": {
                    "text": "Add workspace",
                    "variant": "primary",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "source",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Trailing icon",
                "args": {
                    "text": "Add workspace",
                    "variant": "primary",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "source",
                    "iconPosition": "trailing",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Theme icon",
                "args": {
                    "text": "Add workspace",
                    "variant": "primary",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "theme",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
                }
            },
            {
                "name": "Loading",
                "args": {
                    "text": "Save changes",
                    "variant": "primary",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": true
                }
            },
            {
                "name": "Compact",
                "args": {
                    "text": "Save",
                    "variant": "primary",
                    "disabled": false,
                    "size": "sm",
                    "iconKind": "none",
                    "iconPosition": "leading",
                    "display": "beside",
                    "loading": false
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
                    "disabled": false,
                    "size": "default",
                    "iconKind": "glyph"
                }
            },
            {
                "name": "Close",
                "args": {
                    "icon": "\u00d7",
                    "label": "Close panel",
                    "variant": "ghost",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "glyph"
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "icon": "+",
                    "label": "Add workspace",
                    "variant": "secondary",
                    "disabled": true,
                    "size": "default",
                    "iconKind": "glyph"
                }
            },
            {
                "name": "Source icon",
                "args": {
                    "icon": "+",
                    "label": "Add workspace",
                    "variant": "secondary",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "source"
                }
            },
            {
                "name": "Theme icon",
                "args": {
                    "icon": "+",
                    "label": "Add workspace",
                    "variant": "secondary",
                    "disabled": false,
                    "size": "default",
                    "iconKind": "theme"
                }
            },
            {
                "name": "Large",
                "args": {
                    "icon": "+",
                    "label": "Add workspace",
                    "variant": "secondary",
                    "disabled": false,
                    "size": "lg",
                    "iconKind": "glyph"
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
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "password": false,
                    "numeric": false
                }
            },
            {
                "name": "Filled",
                "args": {
                    "text": "Personal workspace",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "password": false,
                    "numeric": false
                }
            },
            {
                "name": "Read only",
                "args": {
                    "text": "Shared workspace",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": true,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "password": false,
                    "numeric": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Personal workspace",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": false,
                    "disabled": true,
                    "size": "default",
                    "invalid": false,
                    "password": false,
                    "numeric": false
                }
            },
            {
                "name": "Invalid",
                "args": {
                    "text": "Already taken",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": true,
                    "password": false,
                    "numeric": false
                }
            },
            {
                "name": "Password",
                "args": {
                    "text": "secret-example",
                    "placeholder": "Name your workspace",
                    "label": "Password",
                    "readOnly": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "password": true,
                    "numeric": false
                }
            },
            {
                "name": "Compact",
                "args": {
                    "text": "",
                    "placeholder": "Name your workspace",
                    "label": "Workspace name",
                    "readOnly": false,
                    "disabled": false,
                    "size": "sm",
                    "invalid": false,
                    "password": false,
                    "numeric": false
                }
            },
            {
                "name": "Validated number",
                "args": {
                    "text": "42",
                    "placeholder": "1\u2013999",
                    "label": "Workspace number",
                    "readOnly": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "password": false,
                    "numeric": true
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
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false
                }
            },
            {
                "name": "On",
                "args": {
                    "text": "Do not disturb",
                    "checked": true,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Do not disturb",
                    "checked": true,
                    "disabled": true,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false
                }
            },
            {
                "name": "Description",
                "args": {
                    "text": "Background updates",
                    "checked": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "Keep this workspace up to date when the panel is closed.",
                    "multiline": true
                }
            },
            {
                "name": "Compact",
                "args": {
                    "text": "Notifications",
                    "checked": false,
                    "disabled": false,
                    "size": "sm",
                    "invalid": false,
                    "description": "",
                    "multiline": false
                }
            },
            {
                "name": "Invalid",
                "args": {
                    "text": "Accept the terms",
                    "checked": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": true,
                    "description": "",
                    "multiline": false
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
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false,
                    "tristate": false,
                    "partial": false,
                    "selectAll": false
                }
            },
            {
                "name": "On",
                "args": {
                    "text": "Start on login",
                    "checked": true,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false,
                    "tristate": false,
                    "partial": false,
                    "selectAll": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Start on login",
                    "checked": true,
                    "disabled": true,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false,
                    "tristate": false,
                    "partial": false,
                    "selectAll": false
                }
            },
            {
                "name": "Description",
                "args": {
                    "text": "Background updates",
                    "checked": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "Keep this workspace up to date when the panel is closed.",
                    "multiline": true,
                    "tristate": false,
                    "partial": false,
                    "selectAll": false
                }
            },
            {
                "name": "Compact",
                "args": {
                    "text": "Notifications",
                    "checked": false,
                    "disabled": false,
                    "size": "sm",
                    "invalid": false,
                    "description": "",
                    "multiline": false,
                    "tristate": false,
                    "partial": false,
                    "selectAll": false
                }
            },
            {
                "name": "Invalid",
                "args": {
                    "text": "Accept the terms",
                    "checked": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": true,
                    "description": "",
                    "multiline": false,
                    "tristate": false,
                    "partial": false,
                    "selectAll": false
                }
            },
            {
                "name": "Indeterminate",
                "args": {
                    "text": "Select notifications",
                    "checked": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false,
                    "tristate": true,
                    "partial": true,
                    "selectAll": false
                }
            },
            {
                "name": "Select all",
                "args": {
                    "text": "Select all channels",
                    "checked": false,
                    "disabled": false,
                    "size": "default",
                    "invalid": false,
                    "description": "",
                    "multiline": false,
                    "tristate": false,
                    "partial": false,
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
                    "disabled": false,
                    "vertical": false,
                    "rtl": false,
                    "snap": false,
                    "releaseOnly": false,
                    "step": 1
                }
            },
            {
                "name": "Minimum",
                "args": {
                    "value": 0,
                    "disabled": false,
                    "vertical": false,
                    "rtl": false,
                    "snap": false,
                    "releaseOnly": false,
                    "step": 1
                }
            },
            {
                "name": "Maximum",
                "args": {
                    "value": 100,
                    "disabled": false,
                    "vertical": false,
                    "rtl": false,
                    "snap": false,
                    "releaseOnly": false,
                    "step": 1
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "value": 60,
                    "disabled": true,
                    "vertical": false,
                    "rtl": false,
                    "snap": false,
                    "releaseOnly": false,
                    "step": 1
                }
            },
            {
                "name": "Vertical",
                "args": {
                    "value": 60,
                    "disabled": false,
                    "vertical": true,
                    "rtl": false,
                    "snap": false,
                    "releaseOnly": false,
                    "step": 1
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "value": 60,
                    "disabled": false,
                    "vertical": false,
                    "rtl": true,
                    "snap": false,
                    "releaseOnly": false,
                    "step": 1
                }
            },
            {
                "name": "Snapped steps",
                "args": {
                    "value": 50,
                    "disabled": false,
                    "vertical": false,
                    "rtl": false,
                    "snap": true,
                    "releaseOnly": false,
                    "step": 10
                }
            },
            {
                "name": "Release updates",
                "args": {
                    "value": 60,
                    "disabled": false,
                    "vertical": false,
                    "rtl": false,
                    "snap": false,
                    "releaseOnly": true,
                    "step": 1
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
                    "disabled": false,
                    "size": "default",
                    "placeholder": "Choose an output",
                    "invalid": false,
                    "editable": false,
                    "unavailable": false
                }
            },
            {
                "name": "Headphones",
                "args": {
                    "index": 1,
                    "disabled": false,
                    "size": "default",
                    "placeholder": "Choose an output",
                    "invalid": false,
                    "editable": false,
                    "unavailable": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "index": 0,
                    "disabled": true,
                    "size": "default",
                    "placeholder": "Choose an output",
                    "invalid": false,
                    "editable": false,
                    "unavailable": false
                }
            },
            {
                "name": "Placeholder",
                "args": {
                    "index": -1,
                    "disabled": false,
                    "size": "default",
                    "placeholder": "Choose an output",
                    "invalid": false,
                    "editable": false,
                    "unavailable": false
                }
            },
            {
                "name": "Invalid",
                "args": {
                    "index": -1,
                    "disabled": false,
                    "size": "default",
                    "placeholder": "Choose an output",
                    "invalid": true,
                    "editable": false,
                    "unavailable": false
                }
            },
            {
                "name": "Unavailable option",
                "args": {
                    "index": 0,
                    "disabled": false,
                    "size": "default",
                    "placeholder": "Choose an output",
                    "invalid": false,
                    "editable": false,
                    "unavailable": true
                }
            },
            {
                "name": "Editable",
                "args": {
                    "index": 0,
                    "disabled": false,
                    "size": "default",
                    "placeholder": "Choose an output",
                    "invalid": false,
                    "editable": true,
                    "unavailable": false
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
                    "description": "Build a shell that feels like yours.",
                    "size": "default",
                    "footer": true
                }
            },
            {
                "name": "Long content",
                "args": {
                    "title": "A place for everything",
                    "description": "Cards resize around their content. Compose labels, controls, and layouts while keeping the same shared theme.",
                    "size": "default",
                    "footer": true
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
                    "variant": "neutral",
                    "decoration": "none"
                }
            },
            {
                "name": "Accent",
                "args": {
                    "text": "Connected",
                    "variant": "accent",
                    "decoration": "none"
                }
            },
            {
                "name": "Destructive",
                "args": {
                    "text": "Offline",
                    "variant": "destructive",
                    "decoration": "none"
                }
            },
            {
                "name": "Outline",
                "args": {
                    "text": "Metadata",
                    "variant": "outline",
                    "decoration": "none"
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
                    "variant": "neutral",
                    "decoration": "icon"
                }
            },
            {
                "name": "Syncing",
                "args": {
                    "text": "Syncing",
                    "variant": "neutral",
                    "decoration": "busy"
                }
            },
            {
                "name": "Long label",
                "args": {
                    "text": "A long status label remains inside its available space",
                    "variant": "neutral",
                    "decoration": "none"
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
                    "vertical": false,
                    "semantic": false
                }
            },
            {
                "name": "Vertical",
                "args": {
                    "vertical": true,
                    "semantic": false
                }
            },
            {
                "name": "Semantic",
                "args": {
                    "vertical": false,
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
                "args": {
                    "label": "Workspace name",
                    "description": "Use a name you can recognize in the switcher.",
                    "error": "",
                    "required": false,
                    "largeText": false,
                    "disabled": false
                }
            },
            {
                "name": "Validation error",
                "args": {
                    "label": "Workspace name",
                    "description": "Use a name you can recognize in the switcher.",
                    "error": "This workspace name is already in use.",
                    "required": true,
                    "largeText": false,
                    "disabled": false
                }
            },
            {
                "name": "Large text",
                "args": {
                    "label": "Workspace name",
                    "description": "Use a name you can recognize in the switcher.",
                    "error": "",
                    "required": true,
                    "largeText": true,
                    "disabled": false
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
                    "maximum": 75,
                    "vertical": false,
                    "rtl": false,
                    "disabled": false
                }
            },
            {
                "name": "Vertical",
                "args": {
                    "minimum": 25,
                    "maximum": 75,
                    "vertical": true,
                    "rtl": false,
                    "disabled": false
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "minimum": 25,
                    "maximum": 75,
                    "vertical": false,
                    "rtl": true,
                    "disabled": false
                }
            },
            {
                "name": "Coincident handles",
                "args": {
                    "minimum": 50,
                    "maximum": 50,
                    "vertical": false,
                    "rtl": false,
                    "disabled": false
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "minimum": 25,
                    "maximum": 75,
                    "vertical": false,
                    "rtl": false,
                    "disabled": true
                }
            }
        ]
    },
    {
        "id": "ui-menu",
        "installName": "menu",
        "group": "QuickUI",
        "title": "Menu",
        "description": "Native popup navigation with actions, checks, nested choices and separators.",
        "source": Qt.resolvedUrl("MenuStory.qml"),
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add button menu menu-item menu-separator --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Button {\n    theme: tokens; text: \"Open menu\"\n    onClicked: actions.open()\n    UI.Menu {\n        id: actions; theme: tokens; y: parent.height\n        UI.MenuItem { theme: tokens; text: \"Open\"; onTriggered: console.log(\"open\") }\n        UI.MenuSeparator { theme: tokens }\n        UI.MenuItem { theme: tokens; text: \"Notifications\"; checkable: true; checked: true }\n    }\n}\n\nSource: registry/quickui/Menu.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "controls": [
            {
                "key": "label",
                "label": "Trigger label",
                "type": "text"
            },
            {
                "key": "checked",
                "label": "Notifications",
                "type": "boolean"
            },
            {
                "key": "choice",
                "label": "Arrangement",
                "type": "select",
                "options": [
                    "Compact",
                    "Comfortable"
                ]
            },
            {
                "key": "icons",
                "label": "Icons",
                "type": "boolean"
            },
            {
                "key": "rtl",
                "label": "Right to left",
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
            }
        ],
        "presets": [
            {
                "name": "Workspace actions",
                "args": {
                    "label": "Workspace actions",
                    "checked": true,
                    "choice": "Comfortable",
                    "icons": true,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1
                }
            },
            {
                "name": "Unchecked",
                "args": {
                    "label": "Workspace actions",
                    "checked": false,
                    "choice": "Compact",
                    "icons": true,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "label": "Workspace actions",
                    "checked": true,
                    "choice": "Comfortable",
                    "icons": true,
                    "rtl": true,
                    "density": "default",
                    "fontScale": 1
                }
            },
            {
                "name": "Compact",
                "args": {
                    "label": "Workspace actions",
                    "checked": true,
                    "choice": "Comfortable",
                    "icons": true,
                    "rtl": false,
                    "density": "compact",
                    "fontScale": 1
                }
            },
            {
                "name": "Large text",
                "args": {
                    "label": "Workspace actions",
                    "checked": true,
                    "choice": "Comfortable",
                    "icons": true,
                    "rtl": false,
                    "density": "comfortable",
                    "fontScale": 1.5
                }
            }
        ]
    },
    {
        "id": "ui-menu-item",
        "installName": "menu-item",
        "group": "QuickUI",
        "title": "Menu item",
        "description": "A native action row with icon, shortcut text, check and destructive states.",
        "source": Qt.resolvedUrl("MenuItemStory.qml"),
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add menu-item --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.MenuItem {\n    theme: tokens; text: \"Open workspace\"\n    shortcutText: \"Ctrl+O\" // Display only; bind an Action or Shortcut to register a shortcut.\n    onTriggered: console.log(\"open\")\n}\n\nSource: registry/quickui/MenuItem.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "controls": [
            {
                "key": "text",
                "label": "Label",
                "type": "text"
            },
            {
                "key": "shortcut",
                "label": "Shortcut label",
                "type": "text"
            },
            {
                "key": "icon",
                "label": "Icon",
                "type": "boolean"
            },
            {
                "key": "checkable",
                "label": "Checkable",
                "type": "boolean"
            },
            {
                "key": "checked",
                "label": "Checked",
                "type": "boolean"
            },
            {
                "key": "indicator",
                "label": "Indicator",
                "type": "select",
                "options": [
                    "auto",
                    "check",
                    "radio"
                ]
            },
            {
                "key": "partial",
                "label": "Partial check",
                "type": "boolean"
            },
            {
                "key": "disabled",
                "label": "Disabled",
                "type": "boolean"
            },
            {
                "key": "destructive",
                "label": "Destructive",
                "type": "boolean"
            },
            {
                "key": "rtl",
                "label": "Right to left",
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
            }
        ],
        "presets": [
            {
                "name": "Action",
                "args": {
                    "text": "Open workspace",
                    "shortcut": "Ctrl+O",
                    "icon": false,
                    "checkable": false,
                    "checked": false,
                    "disabled": false,
                    "destructive": false,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "auto",
                    "partial": false
                }
            },
            {
                "name": "Icon",
                "args": {
                    "text": "Open workspace",
                    "shortcut": "Ctrl+O",
                    "icon": true,
                    "checkable": false,
                    "checked": false,
                    "disabled": false,
                    "destructive": false,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "auto",
                    "partial": false
                }
            },
            {
                "name": "Checked",
                "args": {
                    "text": "Notifications",
                    "shortcut": "",
                    "icon": false,
                    "checkable": true,
                    "checked": true,
                    "disabled": false,
                    "destructive": false,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "auto",
                    "partial": false
                }
            },
            {
                "name": "Radio",
                "args": {
                    "text": "Comfortable",
                    "shortcut": "",
                    "icon": false,
                    "checkable": true,
                    "checked": true,
                    "disabled": false,
                    "destructive": false,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "radio",
                    "partial": false
                }
            },
            {
                "name": "Mixed",
                "args": {
                    "text": "Select all",
                    "shortcut": "",
                    "icon": false,
                    "checkable": true,
                    "checked": false,
                    "disabled": false,
                    "destructive": false,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "auto",
                    "partial": true
                }
            },
            {
                "name": "Disabled",
                "args": {
                    "text": "Restore previous session",
                    "shortcut": "",
                    "icon": false,
                    "checkable": false,
                    "checked": false,
                    "disabled": true,
                    "destructive": false,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "auto",
                    "partial": false
                }
            },
            {
                "name": "Destructive",
                "args": {
                    "text": "Delete workspace",
                    "shortcut": "",
                    "icon": false,
                    "checkable": false,
                    "checked": false,
                    "disabled": false,
                    "destructive": true,
                    "rtl": false,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "auto",
                    "partial": false
                }
            },
            {
                "name": "Right to left",
                "args": {
                    "text": "Open workspace",
                    "shortcut": "Ctrl+O",
                    "icon": true,
                    "checkable": false,
                    "checked": false,
                    "disabled": false,
                    "destructive": false,
                    "rtl": true,
                    "density": "default",
                    "fontScale": 1,
                    "indicator": "auto",
                    "partial": false
                }
            },
            {
                "name": "Large text",
                "args": {
                    "text": "Open workspace",
                    "shortcut": "Ctrl+O",
                    "icon": false,
                    "checkable": false,
                    "checked": false,
                    "disabled": false,
                    "destructive": false,
                    "rtl": false,
                    "density": "comfortable",
                    "fontScale": 1.5,
                    "indicator": "auto",
                    "partial": false
                }
            }
        ]
    },
    {
        "id": "ui-menu-separator",
        "installName": "menu-separator",
        "group": "QuickUI",
        "title": "Menu separator",
        "description": "A noninteractive divider between groups of menu actions.",
        "source": Qt.resolvedUrl("MenuSeparatorStory.qml"),
        "usage": "./quickui init --cwd ~/my-shell\n./quickui add menu-separator --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.MenuSeparator { theme: tokens; width: 240 }\n\nSource: registry/quickui/MenuSeparator.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
        "controls": [
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
            }
        ],
        "presets": [
            {
                "name": "Default",
                "args": {
                    "density": "default",
                    "fontScale": 1
                }
            },
            {
                "name": "Compact",
                "args": {
                    "density": "compact",
                    "fontScale": 1
                }
            },
            {
                "name": "Comfortable",
                "args": {
                    "density": "comfortable",
                    "fontScale": 1
                }
            }
        ]
    },
{
    "id": "ui-dialog",
    "installName": "dialog",
    "usage": "./quickui init --cwd ~/my-shell\n./quickui add dialog button text-field --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Button { theme: tokens; text: \"Edit workspace\"; onClicked: editor.open() }\nUI.Dialog { id: editor; theme: tokens; title: \"Edit workspace\"; contentItem: UI.TextField { theme: tokens; placeholderText: \"Workspace name\" } }\n\nSource: registry/quickui/Dialog.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
    "group": "QuickUI",
    "title": "Dialog",
    "description": "A themed native modal with caller-owned content and standard action buttons.",
    "source": Qt.resolvedUrl("DialogStory.qml"),
    "controls": [
        {
            "key": "title",
            "label": "Title",
            "type": "text"
        },
        {
            "key": "name",
            "label": "Workspace name",
            "type": "text"
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
            "key": "radius",
            "label": "Corner radius",
            "type": "number",
            "min": 0,
            "max": 20,
            "step": 1
        }
    ],
    "presets": [
        {
            "name": "Default",
            "args": {
                "title": "Edit workspace",
                "name": "Personal workspace"
            }
        },
        {
            "name": "Large text",
            "args": {
                "title": "Edit workspace",
                "name": "A longer workspace name",
                "fontScale": 1.5,
                "density": "comfortable"
            }
        },
        {
            "name": "Sharp",
            "args": {
                "title": "Edit workspace",
                "name": "Personal workspace",
                "radius": 0
            }
        }
    ]
},
{
    "id": "ui-alert-dialog",
    "installName": "alert-dialog",
    "usage": "./quickui init --cwd ~/my-shell\n./quickui add alert-dialog button --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.Button { theme: tokens; text: \"Remove workspace\"; onClicked: confirmation.open() }\nUI.AlertDialog { id: confirmation; theme: tokens; title: \"Remove workspace?\"; description: \"Only a demonstration event is emitted.\"; confirmText: \"Remove\"; onAccepted: console.log(\"removal requested\") }\n\nSource: registry/quickui/AlertDialog.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
    "group": "QuickUI",
    "title": "Alert dialog",
    "description": "A confirmation with Cancel focused on open; outside clicks do not dismiss it.",
    "source": Qt.resolvedUrl("AlertDialogStory.qml"),
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
            "key": "confirmText",
            "label": "Confirm label",
            "type": "text"
        },
        {
            "key": "variant",
            "label": "Action variant",
            "type": "select",
            "options": [
                "destructive",
                "primary"
            ]
        },
        {
            "key": "disabled",
            "label": "Disable confirmation",
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
            "key": "radius",
            "label": "Corner radius",
            "type": "number",
            "min": 0,
            "max": 20,
            "step": 1
        }
    ],
    "presets": [
        {
            "name": "Destructive",
            "args": {
                "title": "Remove workspace?",
                "confirmText": "Remove",
                "variant": "destructive"
            }
        },
        {
            "name": "Primary",
            "args": {
                "title": "Apply changes?",
                "confirmText": "Apply",
                "variant": "primary"
            }
        },
        {
            "name": "Unavailable",
            "args": {
                "title": "Remove workspace?",
                "confirmText": "Remove",
                "disabled": true
            }
        },
        {
            "name": "Large text",
            "args": {
                "title": "Remove this workspace?",
                "confirmText": "Remove workspace",
                "fontScale": 1.5,
                "density": "comfortable",
                "description": "This is a synthetic example. The component emits a request; the application decides whether and how to perform it."
            }
        }
    ]
},
{
    "id": "ui-list-item",
    "installName": "list-item",
    "usage": "./quickui init --cwd ~/my-shell\n./quickui add list-item --cwd ~/my-shell\n\n// In your shell.qml (inside a window):\nimport \"ui\" as UI\n\nUI.Theme { id: tokens; dark: true; accent: \"#72dce8\" }\nUI.ListItem { theme: tokens; width: 320; text: \"Design notes\"; description: \"Shared workspace\"; onClicked: console.log(\"open requested\") }\n\nSource: registry/quickui/ListItem.qml\nInstalled source is yours to edit. Shared dependencies are preserved.",
    "group": "QuickUI",
    "title": "List item",
    "description": "Native row activation, caller-owned selection, and replaceable content.",
    "source": Qt.resolvedUrl("ListItemStory.qml"),
    "controls": [
        {
            "key": "text",
            "label": "Title",
            "type": "text"
        },
        {
            "key": "description",
            "label": "Description",
            "type": "text"
        },
        {
            "key": "selected",
            "label": "Selected",
            "type": "boolean"
        },
        {
            "key": "highlighted",
            "label": "Cursor highlight",
            "type": "boolean"
        },
        {
            "key": "disabled",
            "label": "Disabled",
            "type": "boolean"
        },
        {
            "key": "slots",
            "label": "Leading and trailing slots",
            "type": "boolean"
        },
        {
            "key": "rtl",
            "label": "Right to left",
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
            "key": "radius",
            "label": "Corner radius",
            "type": "number",
            "min": 0,
            "max": 20,
            "step": 1
        }
    ],
    "presets": [
        {
            "name": "Default",
            "args": {
                "text": "Design notes",
                "description": "Shared notes for the next iteration."
            }
        },
        {
            "name": "Selected with slots",
            "args": {
                "selected": true,
                "slots": true
            }
        },
        {
            "name": "Cursor",
            "args": {
                "highlighted": true
            }
        },
        {
            "name": "Disabled",
            "args": {
                "disabled": true
            }
        },
        {
            "name": "Large RTL",
            "args": {
                "slots": true,
                "fontScale": 1.5,
                "density": "comfortable",
                "rtl": true
            }
        },
        {
            "name": "Sharp compact",
            "args": {
                "radius": 0,
                "density": "compact",
                "size": "sm"
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
                    "reduceMotion": false,
                    "density": "default",
                    "fontScale": 1,
                    "subduedSelection": false
                }
            },
            {
                "name": "Ocean",
                "args": {
                    "palette": "Ocean",
                    "radius": 12,
                    "height": 40,
                    "reduceMotion": false,
                    "density": "default",
                    "fontScale": 1,
                    "subduedSelection": false
                }
            },
            {
                "name": "Sharp",
                "args": {
                    "palette": "Rose",
                    "radius": 0,
                    "height": 36,
                    "reduceMotion": true,
                    "density": "default",
                    "fontScale": 1,
                    "subduedSelection": false
                }
            },
            {
                "name": "Compact",
                "args": {
                    "palette": "Lavender",
                    "radius": 6,
                    "height": 30,
                    "reduceMotion": false,
                    "density": "compact",
                    "fontScale": 1,
                    "subduedSelection": false
                }
            },
            {
                "name": "Large text",
                "args": {
                    "palette": "Lavender",
                    "radius": 8,
                    "height": 44,
                    "reduceMotion": true,
                    "density": "comfortable",
                    "fontScale": 2,
                    "subduedSelection": false
                }
            },
            {
                "name": "Independent selection",
                "args": {
                    "palette": "Ocean",
                    "radius": 8,
                    "height": 36,
                    "reduceMotion": false,
                    "density": "default",
                    "fontScale": 1,
                    "subduedSelection": true
                }
            }
        ]
    }
]
}
