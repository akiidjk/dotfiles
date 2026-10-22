pragma Singleton
import Quickshell
import QtQuick

// Dynamic Island / keybinds / wallpaper picker style: MacShell's palette (MacBar `pal`) under the island's names.
// MacBar hands itself over once (Component.onCompleted), so every Island* file just reads IslandStyle.*.
Singleton {
    id: s
    property var bar: null
    readonly property var pal: bar ? bar.islandPal : null

    readonly property bool dark: pal ? pal.dark : true
    readonly property color fg: pal ? pal.fg : "#FFFFFF"
    readonly property color fg2: pal ? pal.fg2 : Qt.rgba(1, 1, 1, 0.62)
    readonly property color fg3: pal ? pal.fg3 : Qt.rgba(1, 1, 1, 0.34)
    readonly property color accent: pal ? pal.accent : "#0A84FF"
    readonly property color accentFg: "#FFFFFF"
    readonly property color tile: pal ? pal.tile : Qt.rgba(1, 1, 1, 0.10)
    readonly property color tileBorder: pal ? pal.tileBorder : Qt.rgba(1, 1, 1, 0.16)
    readonly property color hover: pal ? pal.hover : Qt.rgba(1, 1, 1, 0.14)
    readonly property color btnOff: pal ? pal.btnOff : Qt.rgba(1, 1, 1, 0.20)
    readonly property color sep: pal ? pal.sep : Qt.rgba(1, 1, 1, 0.14)
    readonly property color track: pal ? pal.track : Qt.rgba(1, 1, 1, 0.20)
    readonly property color danger: "#FF453A"

    readonly property string fam: pal ? pal.fam : "Open Runde"
    readonly property string iconFont: "JetBrains Mono Nerd Font Propo"
    // Open Runde has no real bold: weights >= DemiBold use its Semibold family (same rule as the rest of the shell)
    function font(weight) { return bar ? bar.fontForWeight(weight, fam) : fam; }

    readonly property int aFast: 140
    readonly property int aMed: 240
    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }
}
