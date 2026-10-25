import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

// Now-playing card (expanded notch + hub): art / title / artist / sound bars, progress with times, transport row.
ColumnLayout {
    id: root

    readonly property var player: {
        const ps = Mpris.players?.values ?? [];
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }
    readonly property bool hasTrack: player != null && (player.trackTitle ?? "") !== ""
    readonly property bool playing: player?.isPlaying ?? false
    visible: hasTrack

    spacing: 10

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && root.playing
        onTriggered: root.player?.positionChanged()
    }

    function fmt(s) {
        if (!s || s < 0) s = 0;
        const m = Math.floor(s / 60);
        const x = Math.floor(s % 60);
        return m + ":" + (x < 10 ? "0" : "") + x;
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        IslandArt {
            size: 48
            radius: 11
            url: root.player?.trackArtUrl ?? ""
            Layout.alignment: Qt.AlignVCenter
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2
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
        }
        IslandEq { running: root.playing; Layout.alignment: Qt.AlignTop; Layout.topMargin: 4 }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            text: root.fmt(root.player?.position ?? 0)
            color: IslandStyle.fg2
            font.family: IslandStyle.fam
            font.pixelSize: 10
            font.features: { "tnum": 1 }
        }
        Rectangle {
            id: bar
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: 5
            radius: 2.5
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
            text: root.fmt(root.player?.length ?? 0)
            color: IslandStyle.fg2
            font.family: IslandStyle.fam
            font.pixelSize: 10
            font.features: { "tnum": 1 }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        Layout.rightMargin: 8
        implicitHeight: 26

        IslandPlayerBtn {
            kind: "shuffle"; size: 15
            enabled: root.player?.shuffleSupported ?? false
            on: root.player?.shuffle ?? false
            onActivated: root.player.shuffle = !root.player.shuffle
        }
        Item { Layout.fillWidth: true }
        IslandPlayerBtn {
            kind: "prev"; size: 18
            enabled: root.player?.canGoPrevious ?? false
            onActivated: root.player.previous()
        }
        Item { Layout.fillWidth: true }
        IslandPlayerBtn {
            kind: root.playing ? "pause" : "play"; size: 24
            onActivated: root.player?.togglePlaying()
        }
        Item { Layout.fillWidth: true }
        IslandPlayerBtn {
            kind: "next"; size: 18
            enabled: root.player?.canGoNext ?? false
            onActivated: root.player.next()
        }
        Item { Layout.fillWidth: true }
        IslandPlayerBtn {
            kind: "repeat"; size: 15
            enabled: root.player?.loopSupported ?? false
            on: (root.player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
            onActivated: root.player.loopState = root.player.loopState === MprisLoopState.None ? MprisLoopState.Playlist : MprisLoopState.None
        }
    }
}
