import QtQuick
import "../theme.js" as Theme // Dark-mode
import "../colors.js" as Colors // Light-mode overrides

QtObject {
    id: root
    property bool isDarkMode: true

    // 1) Surfaces
    readonly property color bgMain: Colors.background

    // Card + item surfaces
    readonly property color bgCard: Colors.surface_container
    readonly property color bgItem: Colors.surface_container_low
    readonly property color bgWidget: Colors.surface_container_high

    // 2) Text
    readonly property color textPrimary: Colors.on_surface
    readonly property color textSecondary: Colors.on_surface_variant
    readonly property color textOnAccent: Colors.on_primary

    // 3) Accents
    readonly property color accent: Colors.primary
    readonly property color accentSlider: Colors.tertiary

    // 4) Lines, hovers, misc
    readonly property color border: Colors.outline

    // General outlines used by small controls (avatar ring, tiny pills, etc.)
    readonly property color outline: Colors.outline_variant

    // Subtle fills for small buttons
    readonly property color subtleFill: Colors.surface_container_lowest
    readonly property color subtleFillHover: Colors.surface_container_highest
    readonly property color accentRed: Colors.error

    // Hover spotlight
    readonly property color hoverSpotlight: isDarkMode ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
}
