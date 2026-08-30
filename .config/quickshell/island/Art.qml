import Quickshell.Widgets
import QtQuick
import "../"

// Rounded album-art tile with a glyph placeholder + fade-in.
ClippingRectangle {
    id: root
    property int size: 44
    property string url: ""

    implicitWidth: size
    implicitHeight: size
    color: Appearance.withAlpha(Appearance.colors.surfaceVariantFg, 0.18)

    Text {
        anchors.centerIn: parent
        text: "\u{f001}"                       // music note
        font.family: Config.data.font
        font.pixelSize: root.size * 0.4
        color: Appearance.colors.primary
        opacity: img.status === Image.Ready ? 0 : 0.55
        Behavior on opacity { NumberAnimation { duration: Appearance.aMed } }
    }

    Image {
        id: img
        anchors.fill: parent
        source: root.url
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        asynchronous: true
        cache: true
        opacity: status === Image.Ready ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.aMed } }
    }
}
