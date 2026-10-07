// SPDX-License-Identifier: MIT
/*
MIT License

Copyright (c) 2026 brs98

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

.pragma library

// Inputs use Qt colors (#RRGGBB or #AARRGGBB), including already composed alpha.
function rgba(value) {
    if (value && typeof value.r === "number") return [value.r, value.g, value.b, value.a];
    var hex = String(value || "");
    if (/^#[0-9a-f]{3}$/i.test(hex)) hex = "#" + hex[1] + hex[1] + hex[2] + hex[2] + hex[3] + hex[3];
    if (!/^#(?:[0-9a-f]{6}|[0-9a-f]{8})$/i.test(hex)) return null;
    var alpha = hex.length === 9 ? parseInt(hex.substr(1, 2), 16) / 255 : 1;
    var offset = hex.length === 9 ? 3 : 1;
    return [parseInt(hex.substr(offset, 2), 16) / 255, parseInt(hex.substr(offset + 2, 2), 16) / 255, parseInt(hex.substr(offset + 4, 2), 16) / 255, alpha];
}
function luminance(rgb) {
    var linear = rgb.slice(0, 3).map(function (v) { return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); });
    return linear[0] * 0.2126 + linear[1] * 0.7152 + linear[2] * 0.0722;
}
function contrastForeground(color, background) {
    var fg = rgba(color) || [0, 0, 0, 1];
    var bg = rgba(background) || [0, 0, 0, 1];
    var effective = fg.slice(0, 3).map(function (v, i) { return v * fg[3] + bg[i] * (1 - fg[3]); });
    var light = luminance(effective);
    return (light + 0.05) / 0.05 >= 1.05 / (light + 0.05) ? "#000000" : "#ffffff";
}
function number(value, fallback, minimum) {
    return typeof value === "number" && isFinite(value) && value >= minimum ? value : fallback;
}
function resolve(snapshot) {
    if (!snapshot || !snapshot.colors || !rgba(snapshot.colors.background) || !rgba(snapshot.colors.foreground)) return null;
    var c = snapshot.colors;
    var s = snapshot.style || {};
    var background = c.background;
    var foreground = c.foreground;
    var accent = c.accent || foreground;
    var urgent = c.urgent || "#ba2948";
    var popup = c.popup || background;
    var popupText = c.popupForeground || foreground;
    var radius = number(s.radius, null, 0);
    var tokens = {
        dark: luminance(rgba(background)) < 0.5,
        background: background, surface: popup, surfaceHover: c.surfaceHover || popup,
        foreground: foreground, mutedForeground: c.muted || foreground,
        border: c.border || accent, accent: accent,
        accentForeground: contrastForeground(accent, background),
        destructive: urgent, destructiveForeground: contrastForeground(urgent, background),
        focus: c.focus || accent, primary: accent, primaryForeground: contrastForeground(accent, background),
        selection: c.selection || accent,
        selectionForeground: c.selectionForeground || contrastForeground(c.selection || accent, popup),
        popup: popup, popupForeground: popupText, card: popup, cardForeground: popupText,
        fontFamily: s.fontFamily || "monospace", fontScale: number(s.fontScale, 1, 0.01),
        fontSize: Math.round(number(s.fontSize, 12, 1)), smallFontSize: Math.round(number(s.smallFontSize, 11, 1)),
        spacing: Math.round(number(s.spacing, 8, 0)), padding: Math.round(number(s.padding, 10, 0)),
        controlHeight: Math.round(number(s.controlHeight, 28, 1)), handleSize: Math.round(number(s.handleSize, 14, 1)),
        borderWidth: Math.round(number(s.borderWidth, 1, 0)), focusWidth: Math.round(number(s.focusWidth, 1, 0)),
        density: "default", motionDuration: 120, disabledOpacity: 0.45
    };
    // An unavailable compositor value is not a square theme. Omit the group
    // so HostTheme preserves preset geometry until a real value is available.
    if (radius !== null) {
        tokens.radius = Math.round(radius);
        tokens.radiusSmall = Math.round(tokens.radius * 0.6);
        tokens.radiusLarge = Math.round(tokens.radius * 1.4);
    }
    return tokens;
}
