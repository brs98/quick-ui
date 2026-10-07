#!/usr/bin/env python3
"""Read a bounded, read-only Omarchy desktop theme snapshot for QuickUI.

Only resolved colors.toml, theme shell.toml and user shell.toml are read.
No shell commands, theme activation, IPC mutations, or desktop writes occur.
Missing or malformed inputs clear availability; the QML consumer never presents
an old theme as live. Paths are reopened each poll to follow atomic replacements.
"""
# SPDX-License-Identifier: MIT
# MIT License
#
# Copyright (c) 2026 brs98
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# Token interpretation follows Omarchy shell/Commons/Color.qml and Style.qml.
# See LICENSE.omarchy and THIRD_PARTY_NOTICES.md for upstream attribution.
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
import re
import subprocess
import tomllib

MAX_BYTES = 262144


def read_toml(path: Path, *, required: bool = False) -> dict:
    try:
        with path.open("rb") as stream:
            raw = stream.read(MAX_BYTES + 1)
    except FileNotFoundError:
        if required:
            raise ValueError("Omarchy active theme is unavailable") from None
        return {}
    if len(raw) > MAX_BYTES:
        raise ValueError("Theme input exceeds 256 KiB")
    text = raw.decode("utf-8")
    # Omarchy accepts bare role names and CSS width lists in shell.toml.
    # Quote only that narrow extension, leaving all other parsing to tomllib.
    text = re.sub(r'^(\s*[\w-]+\s*=\s*)([A-Za-z][\w-]*|-?\d+(?:\.\d+)?(?:\s+-?\d+(?:\.\d+)?){1,3})(\s*(?:#.*)?)$',
                  lambda m: m[0] if m[2] in ("true", "false", "inf", "nan") else m[1] + json.dumps(m[2]) + m[3],
                  text, flags=re.M)
    return tomllib.loads(text)


def number(value, default: float) -> float:
    try:
        n = float(value)
        return n if math.isfinite(n) else default
    except (TypeError, ValueError):
        return default


def rounded(value: float) -> int:
    return math.floor(value + .5)


def boolean(value, default=True):
    if value is None:
        return default
    return str(value).lower() not in ("false", "0", "no", "off")


def color(value, fallback, palette, flat=None, seen=()):
    token = str(value or "").strip().split()
    token = next((p for p in token if not p.endswith("deg")), "")
    role = token.lower()
    if flat and role in flat and role not in seen:
        return color(flat[role], fallback, palette, flat, (*seen, role))
    if role in palette:
        return palette[role]
    if role == "text":
        return palette["foreground"]
    if role == "transparent":
        return "#00000000"
    if re.fullmatch(r"#[\da-fA-F]{6}", token):
        return token.lower()
    if re.fullmatch(r"#[\da-fA-F]{3}", token):
        return "#" + "".join(c * 2 for c in token[1:]).lower()
    match = re.fullmatch(r"rgba\(([\da-fA-F]{8})\)", token, flags=re.I)
    if match:
        s = match[1].lower()
        return "#" + s[6:] + s[:6]
    match = re.fullmatch(r"rgb\(([\da-fA-F]{6})\)", token, flags=re.I)
    if match:
        return "#" + match[1].lower()
    # Omarchy Style.colorFromHex interprets eight-digit literals as RGBA.
    if re.fullmatch(r"#[\da-fA-F]{8}", token):
        return "#" + token[7:9].lower() + token[1:7].lower()
    match = re.fullmatch(r"rgba?\((\d+),(\d+),(\d+)(?:,([\d.]+))?\)", token, flags=re.I)
    if match:
        rgb = "#" + "".join(f"{min(255, int(part)):02x}" for part in match.groups()[:3])
        return alpha(rgb, match[4]) if match[4] is not None else rgb
    if re.fullmatch(r"0x[\da-fA-F]{8}", token):
        return "#" + token[2:].lower()
    return fallback


def alpha(value: str, amount) -> str:
    opacity = max(0, min(1, number(amount, 1)))
    return f"#{rounded(opacity * 255):02x}" + value[-6:]


def command_output(command: list[str]) -> str:
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=.5, check=False)
        return result.stdout.strip()[:4096] if result.returncode == 0 else ""
    except (OSError, subprocess.TimeoutExpired):
        return ""


def snapshot(theme_dir: Path, user_shell: Path, *, system: bool = True) -> dict:
    initial = theme_dir.stat()
    base = read_toml(theme_dir / "colors.toml", required=True)
    if not any(key in base for key in ("background", "color0")) or not any(key in base for key in ("foreground", "color7")):
        raise ValueError("Theme must provide foreground and background colors")
    palette = {}
    for role, keys, default in (
        ("background", ("background", "color0"), "#101315"),
        ("foreground", ("foreground", "color7"), "#cacccc"),
        ("accent", ("accent", "color4"), "#cacccc"),
        ("urgent", ("red", "color1"), "#a55555"),
        ("muted", ("muted", "color8", "foreground", "color7"), "#cacccc"),
    ):
        chosen = next((base[k] for k in keys if k in base), default)
        parsed = color(chosen, None, {})
        if parsed is None:
            raise ValueError("Theme contains an invalid foundational color")
        palette[role] = parsed
    flat = {}
    for path in (theme_dir / "shell.toml", user_shell):
        for section, values in read_toml(path).items():
            if isinstance(values, dict):
                flat.update({f"{section}.{key}": value for key, value in values.items()})
    final = theme_dir.stat()
    if (initial.st_dev, initial.st_ino) != (final.st_dev, final.st_ino):
        raise ValueError("Omarchy theme changed while being read; retrying")
    # Style.applyShellValues walks the merged keys in insertion order, treating
    # legacy [style] and [controls] as aliases without preferring either name.
    controls = {k.split(".", 1)[1]: v for k, v in flat.items()
                if k.startswith(("style.", "controls."))}

    def composed(key, fallback, opacity=1):
        return alpha(color(flat.get(key), fallback, palette, flat), flat.get(key + "-alpha", opacity))

    def state(key, default="foreground"):
        return color(controls.get(key + "-color", default), palette["foreground"], palette)

    hover = state("hover-cursor")
    focus_token = controls.get("focus-color", controls.get("hover-cursor-color", "foreground"))
    focus = hover if focus_token in ("hover", "hover-cursor", "inherit") else color(focus_token, palette["foreground"], palette)
    colors = dict(palette, popup=composed("popups.background", palette["background"]),
                  popupForeground=color(flat.get("popups.text"), palette["foreground"], palette, flat),
                  border=composed("popups.border", palette["accent"]),
                  surfaceHover=alpha(hover, controls.get("hover-cursor-fill-alpha", .08)),
                  selection=alpha(state("selected"), controls.get("selected-fill-alpha", .18)),
                  selectionForeground=palette["foreground"],
                  focus=alpha(focus, controls.get("focus-border-alpha", controls.get("hover-cursor-border-alpha", .25))))
    base_size = max(1, int(number(flat.get("font.base-size"), 12)))
    font_scale = base_size / 12
    scale = number(flat.get("spacing.scale"), 1)
    if scale < 0:
        scale = 1
    scale *= font_scale if boolean(flat.get("spacing.scale-with-font")) else 1

    def space(px):
        return max(1, rounded(px * scale)) if px * scale > 0 else 0

    def spacing(key, px):
        n = number(flat.get("spacing." + key), -1)
        return rounded(n) if n >= 0 else space(px)

    def font(key, multiplier):
        n = int(number(flat.get("font." + key), 0))
        return n if n > 0 else max(1, rounded(base_size * multiplier))

    radius = 0
    family = "monospace"
    if system:
        family = command_output(["fc-match", "-f", "%{family[0]}", "monospace"]) or family
        try:
            radius = max(0, number(json.loads(command_output(["hyprctl", "-j", "getoption", "decoration:rounding"]) or "{}").get("int"), 0))
        except (ValueError, AttributeError):
            pass
    normal_width = max(0, rounded(number(controls.get("normal-border-width"), 1)))
    focus_width = max(0, rounded(number(controls.get("focus-border-width"), number(controls.get("hover-cursor-border-width"), normal_width))))
    style = dict(fontFamily=family, fontScale=font_scale, fontSize=font("body", 1),
                 smallFontSize=font("body-small", .917), radius=radius,
                 spacing=spacing("control-gap", 8), padding=spacing("control-padding-x", 10),
                 controlHeight=spacing("control-height", 28), handleSize=space(14),
                 borderWidth=normal_width, focusWidth=focus_width)
    return {"colors": colors, "style": style}


def theme_name(theme_dir: Path) -> str:
    # Current themes may be materialized directories rather than symlinks.
    if theme_dir.name == "theme":
        try:
            with (theme_dir.parent / "theme.name").open("r", encoding="utf-8") as stream:
                name = stream.read(256).strip()
            if name and all(ch.isprintable() for ch in name):
                return name
        except (OSError, UnicodeError):
            pass
    return theme_dir.resolve().name


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--theme-dir", type=Path)
    parser.add_argument("--user-shell", type=Path)
    parser.add_argument("--no-system", action="store_true", help="Skip compositor/font queries (deterministic fixtures)")
    args = parser.parse_args()
    home = Path.home()
    theme = args.theme_dir or home / ".local/state/omarchy/current/theme"
    user = args.user_shell or home / ".config/omarchy/shell.toml"
    try:
        data = snapshot(theme, user, system=not args.no_system)
        result = {"schemaVersion": 1, "available": True, "name": theme_name(theme), "error": "", "snapshot": data}
    except (OSError, ValueError, UnicodeError, tomllib.TOMLDecodeError) as error:
        # Do not echo file contents or arbitrary TOML diagnostics into UI/logs.
        message = str(error) if isinstance(error, ValueError) and not isinstance(error, (tomllib.TOMLDecodeError, UnicodeError)) else "Omarchy theme could not be read"
        result = {"schemaVersion": 1, "available": False, "name": "", "error": message, "snapshot": {}}
    print(json.dumps(result, separators=(",", ":"), allow_nan=False))


if __name__ == "__main__":
    main()
