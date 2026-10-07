"""Portable Omarchy recipe validation and generated theme composition."""
import math
from pathlib import Path

import presetlib

FOLLOW_KEYS = {"colors", "typography", "radius", "spacing"}


def validate(data):
    if (not isinstance(data, dict)
            or set(data) != {"schemaVersion", "kind", "preset", "follow", "radiusMultiplier"}
            or type(data["schemaVersion"]) is not int or data["schemaVersion"] != 1
            or data["kind"] != "quickui-omarchy"):
        raise ValueError("Expected a schemaVersion 1 quickui-omarchy recipe")
    presetlib.decode(data["preset"])
    follow = data["follow"]
    if (not isinstance(follow, dict) or set(follow) != FOLLOW_KEYS
            or any(type(value) is not bool for value in follow.values())):
        raise ValueError("Recipe follow must contain boolean colors, typography, radius, and spacing")
    multiplier = data["radiusMultiplier"]
    if (type(multiplier) not in (int, float) or not 0 <= multiplier <= 2
            or not math.isfinite(multiplier)):
        raise ValueError("Recipe radiusMultiplier must be a finite number between 0 and 2")
    return data


def qml_theme(data):
    validate(data)
    license_text = (Path(__file__).resolve().parent / "LICENSE").read_text().strip()
    lines = ["/*", license_text, "*/", "", "import QtQuick", "", "HostTheme {",
             "    // Bind hostTokens to an optional ShellThemeSource or DesktopThemeSource.",
             "    presetTheme: PresetTheme {}"]
    for key, property_name in (("colors", "followColors"), ("typography", "followTypography"),
                               ("radius", "followRadius"), ("spacing", "followSpacing")):
        lines.append(f"    {property_name}: {str(data['follow'][key]).lower()}")
    lines.extend([f"    radiusMultiplier: {data['radiusMultiplier']}", "}", ""])
    return "\n".join(lines).encode()
