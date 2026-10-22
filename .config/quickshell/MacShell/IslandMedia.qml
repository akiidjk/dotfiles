import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

// Now-playing card for the hub: art + title/artist + progress + transport (MacShell player glyphs).
RowLayout {
    id: root

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

    IslandArt {
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
            color: IslandStyle.fg
            font.family: IslandStyle.font(Font.DemiBold)
            font.weight: Font.DemiBold
            font.pixelSize: 13
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            text: root.player?.trackArtist ?? ""
            color: IslandStyle.fg2
            font.family: IslandStyle.fam
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
                height: 4
                radius: 2
                color: IslandStyle.track
                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    color: IslandStyle.fg
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
                        if (len > 0) root.player.position = Math.max(0, Math.min(1, (e.x - 6) / bar.width)) * len;
                    }
                }
            }
            Text {
                anchors.left: parent.left
                anchors.top: bar.bottom
                anchors.topMargin: 2
                text: root.fmt(root.player?.position ?? 0)
                color: IslandStyle.fg3
                font.family: IslandStyle.fam
                font.pixelSize: 9
            }
            Text {
                anchors.right: parent.right
                anchors.top: bar.bottom
                anchors.topMargin: 2
                text: root.fmt(root.player?.length ?? 0)
                color: IslandStyle.fg3
                font.family: IslandStyle.fam
                font.pixelSize: 9
            }
        }
    }

    Row {
        Layout.alignment: Qt.AlignVCenter
        spacing: 12

        IslandPlayerBtn {
            kind: "prev"
            enabled: root.player?.canGoPrevious ?? false
            onActivated: root.player.previous()
        }
        IslandPlayerBtn {
            kind: (root.player?.isPlaying ?? false) ? "pause" : "play"
            size: 22
            onActivated: root.player?.togglePlaying()
        }
        IslandPlayerBtn {
            kind: "next"
            enabled: root.player?.canGoNext ?? false
            onActivated: root.player.next()
        }
    }
}
