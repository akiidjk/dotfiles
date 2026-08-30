pragma Singleton
import Quickshell
import QtQuick
import "colors.js" as Colors
import "theme.js" as Theme

// Maps the shared matugen palette (colors.js) + theme.js onto the role names the
// island uses, so it stays in sync with wallpicker / keybindings / the rest.
Singleton {
    id: root

    // geometry / motion tokens
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 16
    readonly property int radiusLarge: Theme.radiusOuter
    readonly property int gap: 10
    readonly property int gapSmall: 6
    readonly property int aFast: 140
    readonly property int aMed: 240
    readonly property int aSlow: 360
    readonly property real overshoot: 0.9
    readonly property string fontDisplay: Theme.textFont
    readonly property string fontText: Theme.textFont

    function withAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    readonly property QtObject colors: QtObject {
        readonly property color background: Colors.background
        readonly property color backgroundFg: Colors.on_background
        readonly property color surface: Colors.surface
        readonly property color surfaceContainer: Colors.surface_container
        readonly property color surfaceContainerHigh: Colors.surface_container_high
        readonly property color surfaceFg: Colors.on_surface
        readonly property color surfaceVariantFg: Colors.on_surface_variant
        readonly property color primary: Colors.primary
        readonly property color primaryFg: Colors.on_primary
        readonly property color primaryContainer: Colors.primary_container
        readonly property color primaryContainerFg: Colors.on_primary_container
        readonly property color secondary: Colors.secondary
        readonly property color tertiary: Colors.tertiary
        readonly property color outline: Colors.outline
        readonly property color errorColor: Colors.error
    }
}
