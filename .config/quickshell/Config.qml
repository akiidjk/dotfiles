pragma Singleton
import Quickshell
import QtQuick
import "theme.js" as Theme

Singleton {
    id: root
    readonly property QtObject data: QtObject {
        readonly property string font: Theme.iconFont        // glyphs
        readonly property string fontDisplay: Theme.textFont // text
        readonly property string clockFormat: "HH:mm"

        readonly property bool showIsland: true
        readonly property bool showWorkspaces: true
        readonly property bool showTray: true
        readonly property bool showBattery: true
        readonly property bool showAudio: true

        readonly property int animFast: 150
        readonly property int animNormal: 250
    }
}
