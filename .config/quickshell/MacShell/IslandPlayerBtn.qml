import QtQuick

// prev / play / pause / next with MacShell's hand-drawn player glyphs (PlayerGlyph.qml).
Item {
    id: b
    property string kind: "play"
    property real size: 18
    signal activated

    width: size; height: size
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    opacity: enabled ? 1 : 0.35
    scale: ma.pressed ? 0.85 : 1
    Behavior on scale { NumberAnimation { duration: 90 } }

    PlayerGlyph {
        anchors.fill: parent
        kind: b.kind
        col: ma.containsMouse ? IslandStyle.accent : IslandStyle.fg
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.margins: -7
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: b.activated()
    }
}
