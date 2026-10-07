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

import QtQuick

// A portable composition layer. Hosts supply resolved tokens; preset owns overrides.
Theme {
    id: root
    property Theme presetTheme: Theme {}
    property var hostTokens: null
    property bool followColors: true
    property bool followTypography: true
    property bool followRadius: true
    property bool followSpacing: true
    property real radiusMultiplier: 1
    readonly property bool hasHostRadius: followRadius && hostTokens !== null && typeof hostTokens.radius === "number" && isFinite(hostTokens.radius) && hostTokens.radius >= 0
    readonly property real effectiveRadiusMultiplier: isFinite(radiusMultiplier) ? Math.max(0, Math.min(2, radiusMultiplier)) : 1

    function token(name, follow) {
        const value = hostTokens ? hostTokens[name] : undefined;
        return follow && value !== undefined && value !== null ? value : presetTheme[name];
    }
    dark: token("dark", followColors)
    background: token("background", followColors)
    surface: token("surface", followColors)
    surfaceHover: token("surfaceHover", followColors)
    foreground: token("foreground", followColors)
    mutedForeground: token("mutedForeground", followColors)
    border: token("border", followColors)
    accent: token("accent", followColors)
    accentForeground: token("accentForeground", followColors)
    destructive: token("destructive", followColors)
    destructiveForeground: token("destructiveForeground", followColors)
    focus: token("focus", followColors)
    primary: token("primary", followColors)
    primaryForeground: token("primaryForeground", followColors)
    selection: token("selection", followColors)
    selectionForeground: token("selectionForeground", followColors)
    popup: token("popup", followColors)
    popupForeground: token("popupForeground", followColors)
    card: token("card", followColors)
    cardForeground: token("cardForeground", followColors)
    fontFamily: token("fontFamily", followTypography)
    fontScale: token("fontScale", followTypography)
    fontSize: token("fontSize", followTypography)
    smallFontSize: token("smallFontSize", followTypography)
    // Scale only host radii. Missing host values retain the exact preset geometry.
    radius: hasHostRadius ? Math.round(hostTokens.radius * effectiveRadiusMultiplier) : presetTheme.radius
    radiusSmall: hasHostRadius ? Math.round(radius * 0.6) : presetTheme.radiusSmall
    radiusLarge: hasHostRadius ? Math.round(radius * 1.4) : presetTheme.radiusLarge
    spacing: token("spacing", followSpacing)
    padding: token("padding", followSpacing)
    controlHeight: token("controlHeight", followSpacing)
    handleSize: token("handleSize", followSpacing)
    borderWidth: token("borderWidth", followSpacing)
    focusWidth: token("focusWidth", followSpacing)
    density: presetTheme.density
    motionDuration: presetTheme.motionDuration
    disabledOpacity: presetTheme.disabledOpacity
}
