pragma Singleton
import Quickshell
import QtQuick

// Dynamic Island / keybinds / wallpaper picker style. The island is a black notch in every theme, so its colours are
// fixed light-on-black (accent still follows MacShell); the glass panels read `theme` (MacBar `pal`) instead.
// MacBar hands itself over once (Component.onCompleted), so every Island* file just reads IslandStyle.*.
Singleton {
    id: s
    property var bar: null
    readonly property var pal: bar ? bar.islandPal : null
    readonly property var theme: pal ?? s

    readonly property bool dark: true
    readonly property color fg: "#FFFFFF"
    readonly property color fg2: Qt.rgba(1, 1, 1, 0.62)
    readonly property color fg3: Qt.rgba(1, 1, 1, 0.34)
    readonly property color accent: pal ? pal.accent : "#0A84FF"
    readonly property color accentFg: "#FFFFFF"
    readonly property color tile: Qt.rgba(1, 1, 1, 0.10)
    readonly property color tileBorder: Qt.rgba(1, 1, 1, 0.16)
    readonly property color hover: Qt.rgba(1, 1, 1, 0.14)
    readonly property color btnOff: Qt.rgba(1, 1, 1, 0.20)
    readonly property color sep: Qt.rgba(1, 1, 1, 0.14)
    readonly property color track: Qt.rgba(1, 1, 1, 0.20)
    readonly property color danger: "#FF453A"

    readonly property string fam: pal ? pal.fam : "Open Runde"
    readonly property string iconFont: "JetBrains Mono Nerd Font Propo"
    // Open Runde has no real bold: weights >= DemiBold use its Semibold family (same rule as the rest of the shell)
    function font(weight) { return bar ? bar.fontForWeight(weight, fam) : fam; }

    readonly property int aFast: 140
    readonly property int aMed: 240
    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }
}
