import Quickshell.Widgets
import QtQuick

// Rounded album-art tile with a music-note placeholder + fade-in.
ClippingRectangle {
    id: root
    property int size: 44
    property string url: ""

    implicitWidth: size
    implicitHeight: size
    color: IslandStyle.tile

    Image {
        anchors.centerIn: parent
        width: root.size * 0.5; height: width
        source: "assets/music-note.svg"
        sourceSize: Qt.size(width * 2, height * 2)
        fillMode: Image.PreserveAspectFit
        opacity: img.status === Image.Ready ? 0 : 0.55
        Behavior on opacity { NumberAnimation { duration: IslandStyle.aMed } }
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
        Behavior on opacity { NumberAnimation { duration: IslandStyle.aMed } }
    }
}
