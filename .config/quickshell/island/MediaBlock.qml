import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import "../"

// Now-playing card for the hub: art + title/artist + progress + transport.
RowLayout {
    id: root
    readonly property var col: Appearance.colors

    readonly property var player: {
        const ps = Mpris.players?.values ?? [];
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }
    readonly property bool hasTrack: player != null && (player.trackTitle ?? "") !== ""
    visible: hasTrack

    spacing: 12

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && (root.player?.isPlaying ?? false)
        onTriggered: root.player?.positionChanged()
    }

    function fmt(s) {
        if (!s || s < 0) s = 0;
        const m = Math.floor(s / 60);
        const x = Math.floor(s % 60);
        return m + ":" + (x < 10 ? "0" : "") + x;
    }

    Art {
        size: 54
        radius: 12
        url: root.player?.trackArtUrl ?? ""
        Layout.alignment: Qt.AlignVCenter
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        spacing: 3

        Text {
            Layout.fillWidth: true
            text: root.player?.trackTitle ?? ""
            color: root.col.backgroundFg
            font.family: Config.data.fontDisplay
            font.pixelSize: 13
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            text: root.player?.trackArtist ?? ""
            color: root.col.surfaceVariantFg
            font.family: Config.data.fontDisplay
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 14
            Rectangle {
                id: bar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 3
                radius: 1.5
                color: Appearance.withAlpha(root.col.surfaceVariantFg, 0.28)
                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    color: root.col.primary
                    width: {
                        const len = root.player?.length ?? 0;
                        return len > 0 ? parent.width * Math.min(1, root.player.position / len) : 0;
                    }
                    Behavior on width { NumberAnimation { duration: 900; easing.type: Easing.Linear } }
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: (root.player?.canSeek ?? false)
                    onPressed: e => {
                        const len = root.player?.length ?? 0;
                        if (len > 0) root.player.position = Math.max(0, Math.min(1, (e.x + 6) / bar.width)) * len;
                    }
                }
            }
            Text {
                anchors.left: parent.left
                anchors.top: bar.bottom
                anchors.topMargin: 2
                text: root.fmt(root.player?.position ?? 0)
                color: root.col.surfaceVariantFg
                font.family: Config.data.fontDisplay
                font.pixelSize: 9
            }
            Text {
                anchors.right: parent.right
                anchors.top: bar.bottom
                anchors.topMargin: 2
                text: root.fmt(root.player?.length ?? 0)
                color: root.col.surfaceVariantFg
                font.family: Config.data.fontDisplay
                font.pixelSize: 9
            }
        }
    }

    Row {
        Layout.alignment: Qt.AlignVCenter
        spacing: 14

        Ctl {
            glyph: "\u{f048}"
            dim: !(root.player?.canGoPrevious ?? false)
            onActivated: if (root.player?.canGoPrevious) root.player.previous()
        }
        Ctl {
            glyph: (root.player?.isPlaying ?? false) ? "\u{f04c}" : "\u{f04b}"
            gsize: 17
            onActivated: root.player?.togglePlaying()
        }
        Ctl {
            glyph: "\u{f051}"
            dim: !(root.player?.canGoNext ?? false)
            onActivated: if (root.player?.canGoNext) root.player.next()
        }
    }

    component Ctl: Text {
        property string glyph
        property bool dim: false
        property int gsize: 15
        signal activated
        anchors.verticalCenter: parent.verticalCenter
        text: glyph
        font.family: Config.data.font
        font.pixelSize: gsize
        color: cma.containsMouse ? Appearance.colors.primary : Appearance.colors.backgroundFg
        opacity: dim ? 0.35 : 1
        scale: cma.pressed ? 0.85 : 1
        Behavior on color { ColorAnimation { duration: Appearance.aFast } }
        Behavior on scale { NumberAnimation { duration: 90 } }
        MouseArea {
            id: cma
            anchors.fill: parent
            anchors.margins: -7
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.activated()
        }
    }
}
