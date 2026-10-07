// Generated from presets/catalog.json; do not edit.
.pragma library
var catalog = {
  "schemaVersion": 1,
  "codeVersion": "q1",
  "options": [
    {
      "key": "colorSource",
      "label": "Color source",
      "values": [
        {
          "value": "preset",
          "label": "Preset"
        },
        {
          "value": "system",
          "label": "Host colors"
        }
      ]
    },
    {
      "key": "palette",
      "label": "Palette",
      "values": [
        {
          "value": "neutral",
          "label": "Neutral"
        },
        {
          "value": "slate",
          "label": "Slate"
        },
        {
          "value": "warm",
          "label": "Warm"
        }
      ]
    },
    {
      "key": "accent",
      "label": "Accent",
      "values": [
        {
          "value": "lavender",
          "label": "Lavender"
        },
        {
          "value": "ocean",
          "label": "Ocean"
        },
        {
          "value": "rose",
          "label": "Rose"
        },
        {
          "value": "green",
          "label": "Green"
        },
        {
          "value": "amber",
          "label": "Amber"
        }
      ]
    },
    {
      "key": "font",
      "label": "Font",
      "values": [
        {
          "value": "sans",
          "label": "Sans"
        },
        {
          "value": "serif",
          "label": "Serif"
        },
        {
          "value": "mono",
          "label": "Mono"
        }
      ]
    },
    {
      "key": "density",
      "label": "Density",
      "values": [
        {
          "value": "compact",
          "label": "Compact"
        },
        {
          "value": "default",
          "label": "Default"
        },
        {
          "value": "comfortable",
          "label": "Comfortable"
        }
      ]
    },
    {
      "key": "radius",
      "label": "Radius",
      "values": [
        {
          "value": "none",
          "label": "None"
        },
        {
          "value": "small",
          "label": "Small"
        },
        {
          "value": "default",
          "label": "Default"
        },
        {
          "value": "large",
          "label": "Large"
        }
      ]
    },
    {
      "key": "border",
      "label": "Border",
      "values": [
        {
          "value": "none",
          "label": "None"
        },
        {
          "value": "thin",
          "label": "Thin"
        },
        {
          "value": "strong",
          "label": "Strong"
        }
      ]
    },
    {
      "key": "selection",
      "label": "Selection",
      "values": [
        {
          "value": "subtle",
          "label": "Subtle"
        },
        {
          "value": "accent",
          "label": "Accent"
        }
      ]
    },
    {
      "key": "motion",
      "label": "Motion",
      "values": [
        {
          "value": "none",
          "label": "None"
        },
        {
          "value": "normal",
          "label": "Normal"
        }
      ]
    }
  ],
  "defaults": {
    "colorSource": "preset",
    "palette": "neutral",
    "accent": "lavender",
    "font": "sans",
    "density": "default",
    "radius": "default",
    "border": "thin",
    "selection": "subtle",
    "motion": "normal"
  },
  "palettes": {
    "neutral": {
      "dark": {
        "background": "#16161a",
        "surface": "#202026",
        "surfaceHover": "#303038",
        "foreground": "#f2f2f5",
        "mutedForeground": "#b5b5c1",
        "border": "#575765"
      },
      "light": {
        "background": "#f5f5f7",
        "surface": "#ffffff",
        "surfaceHover": "#e7e7ed",
        "foreground": "#202026",
        "mutedForeground": "#555563",
        "border": "#b7b7c3"
      }
    },
    "slate": {
      "dark": {
        "background": "#111923",
        "surface": "#192532",
        "surfaceHover": "#2b3b4e",
        "foreground": "#edf4ff",
        "mutedForeground": "#afc1d8",
        "border": "#4c657e"
      },
      "light": {
        "background": "#f1f5fa",
        "surface": "#ffffff",
        "surfaceHover": "#dfe8f2",
        "foreground": "#17293d",
        "mutedForeground": "#4a6179",
        "border": "#a3b7ce"
      }
    },
    "warm": {
      "dark": {
        "background": "#211913",
        "surface": "#2d231c",
        "surfaceHover": "#44372b",
        "foreground": "#fff4e6",
        "mutedForeground": "#d0bda8",
        "border": "#78624b"
      },
      "light": {
        "background": "#fff7ec",
        "surface": "#fffcf6",
        "surfaceHover": "#efe2ce",
        "foreground": "#332519",
        "mutedForeground": "#715a43",
        "border": "#c5aa8a"
      }
    }
  },
  "accents": {
    "lavender": {
      "dark": "#b9a4ff",
      "light": "#6341bc"
    },
    "ocean": {
      "dark": "#70ceff",
      "light": "#006598"
    },
    "rose": {
      "dark": "#ff9cb8",
      "light": "#a52c53"
    },
    "green": {
      "dark": "#75dda7",
      "light": "#176d46"
    },
    "amber": {
      "dark": "#f3c16d",
      "light": "#875215"
    }
  },
  "accentForeground": {
    "dark": "#14151c",
    "light": "#ffffff"
  },
  "destructive": {
    "dark": "#ff9caf",
    "light": "#b32446"
  },
  "fonts": {
    "sans": "sans-serif",
    "serif": "serif",
    "mono": "monospace"
  },
  "densities": {
    "compact": {
      "controlHeight": 30,
      "padding": 8,
      "spacing": 6
    },
    "default": {
      "controlHeight": 36,
      "padding": 12,
      "spacing": 8
    },
    "comfortable": {
      "controlHeight": 44,
      "padding": 16,
      "spacing": 10
    }
  },
  "radii": {
    "none": 0,
    "small": 4,
    "default": 8,
    "large": 14
  },
  "borders": {
    "none": 0,
    "thin": 1,
    "strong": 2
  },
  "motions": {
    "none": 0,
    "normal": 120
  }
};
