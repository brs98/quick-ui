// Generated from presets/codec.js.in; run python3 scripts/generate_presets.py.
.pragma library
.import "PresetCatalog.js" as Data
var catalog = Data.catalog;
var options = catalog.options;
function defaults() { return JSON.parse(JSON.stringify(catalog.defaults)); }
function validate(config) {
    if (config === null || typeof config !== "object" || Array.isArray(config)
        || Object.keys(config).length !== options.length) throw new Error("Preset config must contain exactly the supported option keys");
    for (var i=0; i<options.length; i++) {
        var group=options[i];
        if (!Object.prototype.hasOwnProperty.call(config,group.key) || typeof config[group.key] !== "string"
            || !group.values.some(function(choice) {return choice.value === config[group.key];}))
            throw new Error("Invalid preset option: " + group.key);
    }
    return config;
}
function encode(config) {
    validate(config);
    var number=0, factor=1;
    for (var i=0; i<options.length; i++) {
        var group=options[i];
        number += group.values.map(function(choice){return choice.value;}).indexOf(config[group.key])*factor;
        factor *= group.values.length;
    }
    return "q1-" + number.toString(36);
}
function decode(code) {
    if (typeof code !== "string" || code.length>16 || !/^q1-(0|[1-9a-z][0-9a-z]*)$/.test(code))
        throw new Error("Invalid or unsupported preset code; expected canonical q1-<base36>");
    var number=parseInt(code.slice(3),36), config={};
    for (var i=0; i<options.length; i++) {
        var group=options[i], index=number % group.values.length;
        config[group.key]=group.values[index].value;
        number=Math.floor(number/group.values.length);
    }
    if (number !== 0 || encode(config) !== code) throw new Error("Preset code is outside the v1 option space");
    return config;
}
function resolve(config,dark) {
    validate(config);
    if (typeof dark !== "boolean") throw new Error("dark must be a boolean");
    var mode=dark?"dark":"light";
    var tokens=JSON.parse(JSON.stringify(catalog.palettes[config.palette][mode]));
    var accent=catalog.accents[config.accent][mode], accentForeground=catalog.accentForeground[mode];
    tokens.accent=accent; tokens.accentForeground=accentForeground;
    tokens.destructive=catalog.destructive[mode]; tokens.destructiveForeground=accentForeground;
    tokens.focus=accent; tokens.primary=accent; tokens.primaryForeground=accentForeground;
    tokens.selection=config.selection === "accent"?accent:tokens.surfaceHover;
    tokens.selectionForeground=config.selection === "accent"?accentForeground:tokens.foreground;
    tokens.popup=tokens.surface; tokens.popupForeground=tokens.foreground;
    tokens.card=tokens.surface; tokens.cardForeground=tokens.foreground;
    tokens.dark=dark; tokens.fontFamily=catalog.fonts[config.font]; tokens.fontScale=1;
    tokens.fontSize=13; tokens.smallFontSize=11; tokens.density=config.density;
    var dimensions=catalog.densities[config.density];
    Object.keys(dimensions).forEach(function(key){tokens[key]=dimensions[key];});
    tokens.radius=catalog.radii[config.radius];tokens.radiusSmall=Math.round(tokens.radius*.6);tokens.radiusLarge=Math.round(tokens.radius*1.4);
    tokens.handleSize=18;tokens.borderWidth=catalog.borders[config.border];tokens.focusWidth=2;
    tokens.motionDuration=catalog.motions[config.motion];tokens.disabledOpacity=.45;
    return tokens;
}
