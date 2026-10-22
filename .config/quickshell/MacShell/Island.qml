import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

// Dynamic Island: the alternative top bar (Settings → Menu Bar → Top bar). A centre pill holds workspaces + clock
// (and now-playing when something plays); hovering expands it into the full bar with tray, volume, date and transport
// controls; clicking (or Super+N) opens the hub.
//
// Created per screen by MacBar.qml. The Liquid Glass slab is handed in by MacBar as a child (it lands in `glass`,
// behind the card) together with the backdrop component, so this file never refers to MacBar's own types.
PanelWindow {
    id: island

    property var bar: null
    property Component backdrop: null          // MacBar's backdropComp (wallpaper + windows behind the glass)
    property bool focusedScreen: true          // this screen gets keyboard-less requests (hub toggle)
    default property alias glass: glassHost.data
    readonly property Item backdropItem: bdLoader.item

    readonly property int topMargin: 8
    readonly property int maxW: 860
    readonly property int maxH: 54
    readonly property int collapsedH: 36
    readonly property int hubMaxH: 780   // window must be tall enough for the open hub + notifs

    visible: bar !== null && bar.topBar === "island" && !bar.topBarHidden

    anchors { top: true; left: true; right: true }
    implicitHeight: hubMaxH + topMargin * 2 + 24   // fixed — surface never resizes
    exclusiveZone: collapsedH + topMargin
    color: "transparent"
    WlrLayershell.namespace: "macisland"
    WlrLayershell.layer: WlrLayer.Top
    mask: Region { item: hitArea }

    // Hyprland monitor for this island's screen — Workspaces shows this monitor's desktops
    readonly property var hyprMonitor: screen ? Hyprland.monitorFor(screen) : null

    // ── player ────────────────────────────────────────────
    readonly property var player: {
        const ps = Mpris.players?.values ?? [];
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }
    readonly property bool hasTrack: player != null && (player.trackTitle ?? "") !== ""
    readonly property bool playing: player != null && player.isPlaying

    property bool autoShow: false
    Timer { id: autoShowTimer; interval: 3000; onTriggered: island.autoShow = false }
    Connections {
        target: island.player
        ignoreUnknownSignals: true
        function onTrackTitleChanged() {
            if (island.playing) {
                island.autoShow = true;
                autoShowTimer.restart();
            }
        }
    }

    // ── expand: hover (transient bar) or click / Super+N (open the hub) ────
    Timer { id: lingerTimer; interval: 350 }
    property bool hubOpen: false
    onHubOpenChanged: if (hubOpen && bar) bar.notifUnread = 0
    onVisibleChanged: if (!visible) hubOpen = false
    Connections {
        target: island.bar
        function onIslandHubRequest() { if (island.focusedScreen && island.visible) island.hubOpen = !island.hubOpen; }
    }
    // cardHover (a HoverHandler) reports hover over the whole card regardless of which child MouseArea has the pointer
    readonly property bool hovered: cardHover.hovered || edgeHover.containsMouse || lingerTimer.running

    HyprlandFocusGrab {
        id: grab
        windows: [island]
        active: island.hubOpen
        property bool settled: false
        onActiveChanged: { settled = false; if (active) settleTimer.restart(); }
        onCleared: if (grab.settled) island.hubOpen = false
    }
    Timer { id: settleTimer; interval: 250; onTriggered: grab.settled = true }

    readonly property bool media: playing || autoShow
    readonly property string mode: hubOpen ? "hub" : (hovered ? "full" : (media && hasTrack ? "compact" : "bar"))

    readonly property int cardW: mode === "hub" ? 468 : mode === "full" ? maxW : mode === "compact" ? 520 : 300
    readonly property int cardH: mode === "hub" ? Math.min(hubMaxH, Math.ceil(hubView.implicitHeight + 28)) : mode === "full" ? maxH : collapsedH
    readonly property int cardR: mode === "hub" ? 28 : mode === "full" ? 24 : 18
    // the card's live geometry (animated) — the glass slab handed in by MacBar follows these
    readonly property real cardX: card.x
    readonly property real cardY: card.y
    readonly property real cardWidth: card.width
    readonly property real cardHeight: card.height
    readonly property real cardRadius: card.radius

    SystemClock { id: dateClock; precision: SystemClock.Minutes }

    Timer {
        interval: 1000
        repeat: true
        running: island.mode === "full" && island.playing
        onTriggered: island.player?.positionChanged()
    }

    // the wallpaper + windows behind the glass (kept warm while the island is shown)
    Loader {
        id: bdLoader
        active: island.bar !== null && island.bar.liquidActive && island.backdrop !== null
        sourceComponent: island.backdrop
        onLoaded: {
            item.hostShown = Qt.binding(function () { return island.visible; });
            item.region = Qt.binding(function () { return Qt.rect(card.x - 96, 0, card.width + 192, card.y + card.height + 96); });
        }
    }

    // fixed hit target -> input mask follows the card only
    Item {
        id: hitArea
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: island.cardW
        height: island.cardH + island.topMargin
    }

    // top-edge hover zone (overlaps the card's top so there's no dead gap)
    MouseArea {
        id: edgeHover
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 520
        height: island.topMargin + 8
        hoverEnabled: true
        onEntered: lingerTimer.stop()
        onExited: lingerTimer.restart()
    }

    // Liquid Glass slab (from MacBar) — same geometry as the card, not clipped so its rim / shadow stay intact
    Item {
        id: glassHost
        x: card.x; y: card.y
        width: card.width; height: card.height
    }
    MenuBorder {
        z: 2
        x: card.x; y: card.y
        width: card.width; height: card.height
        cornerR: card.radius
        dark: IslandStyle.dark
        tint: island.bar ? island.bar.menuBorderColor : "#8A9AB5"
    }

    Item {
        id: card
        z: 3
        x: Math.round((island.width - width) / 2)
        y: island.topMargin
        width: island.cardW
        height: island.cardH
        property real radius: island.cardR
        clip: true

        Behavior on width { NumberAnimation { duration: IslandStyle.aMed; easing.type: Easing.OutBack; easing.overshoot: 0.9 } }
        Behavior on height { NumberAnimation { duration: IslandStyle.aMed; easing.type: Easing.OutCubic } }
        Behavior on radius { NumberAnimation { duration: IslandStyle.aMed; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: island.hubOpen = !island.hubOpen
        }

        // whole-card hover that child MouseAreas can't steal (blocking:false = passes through)
        HoverHandler {
            id: cardHover
            onHoveredChanged: hovered ? lingerTimer.stop() : lingerTimer.restart()
        }

        // ═══════════ collapsed row — minimal: clock (+ now-playing) ═══════════
        RowLayout {
            id: barView
            readonly property bool compact: island.mode === "compact"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: barView.compact ? 12 : 10
            anchors.rightMargin: barView.compact ? 12 : 10
            height: island.collapsedH
            spacing: 9
            opacity: (island.mode === "bar" || barView.compact) ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

            IslandWorkspaces { monitor: island.hyprMonitor; Layout.alignment: Qt.AlignVCenter }

            Rectangle { Layout.alignment: Qt.AlignVCenter; implicitWidth: 1; implicitHeight: 16; color: IslandStyle.sep }

            Item { Layout.fillWidth: true; visible: island.mode === "bar" }

            IslandArt {
                size: 20
                radius: 6
                url: island.player?.trackArtUrl ?? ""
                Layout.alignment: Qt.AlignVCenter
                visible: barView.compact
            }
            Text {
                Layout.fillWidth: true
                visible: barView.compact
                text: island.player?.trackTitle ?? ""
                color: IslandStyle.fg
                font.family: IslandStyle.font(Font.Medium)
                font.weight: Font.Medium
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            // animated sound bars — grow up from a fixed baseline
            Row {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 2
                spacing: 2
                visible: barView.compact
                Repeater {
                    model: 4
                    Item {
                        id: eqCell
                        required property int index
                        width: 3
                        height: 14
                        Rectangle {
                            id: eqBar
                            readonly property int half: 380 + eqCell.index * 110
                            width: parent.width
                            radius: 1.5
                            color: IslandStyle.accent
                            anchors.bottom: parent.bottom
                            height: 3
                            SequentialAnimation on height {
                                running: island.playing
                                loops: Animation.Infinite
                                NumberAnimation { to: 13; duration: eqBar.half; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 3; duration: eqBar.half; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.alignment: Qt.AlignVCenter; visible: barView.compact; implicitWidth: 1; implicitHeight: 14; color: IslandStyle.sep }

            IslandClock { Layout.alignment: Qt.AlignVCenter }

            Item { Layout.fillWidth: true; visible: island.mode === "bar" }

            // unread-notification badge — only in compact (now-playing) mode, only while unread > 0
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: 4
                readonly property int unread: island.bar ? island.bar.notifUnread : 0
                visible: island.mode === "compact" && unread > 0
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\u{f0f3}"
                    font.family: IslandStyle.iconFont
                    font.pixelSize: 13
                    color: IslandStyle.accent
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: Math.max(14, badgeText.implicitWidth + 6)
                    implicitHeight: 14
                    radius: 7
                    color: IslandStyle.accent
                    Text {
                        id: badgeText
                        anchors.centerIn: parent
                        text: parent.parent.unread
                        color: IslandStyle.accentFg
                        font.family: IslandStyle.font(Font.DemiBold)
                        font.weight: Font.DemiBold
                        font.pixelSize: 9
                    }
                }
            }
        }

        // ═══════════════════ full row ═══════════════════════
        RowLayout {
            id: fullView
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12
            opacity: island.mode === "full" ? 1 : 0
            visible: opacity > 0.01
            enabled: island.mode === "full"
            Behavior on opacity { NumberAnimation { duration: IslandStyle.aMed; easing.type: Easing.OutQuad } }

            IslandWorkspaces { monitor: island.hyprMonitor; Layout.alignment: Qt.AlignVCenter }

            Rectangle { Layout.alignment: Qt.AlignVCenter; implicitWidth: 1; implicitHeight: 22; color: IslandStyle.sep }

            // centre: media, or the date when nothing is playing
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 12
                    visible: island.hasTrack

                    IslandArt {
                        size: 34
                        radius: 10
                        url: island.player?.trackArtUrl ?? ""
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            Layout.fillWidth: true
                            text: island.player?.trackTitle ?? ""
                            color: IslandStyle.fg
                            font.family: IslandStyle.font(Font.DemiBold)
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: island.player?.trackArtist ?? ""
                            color: IslandStyle.fg2
                            font.family: IslandStyle.fam
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }
                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 14
                        IslandPlayerBtn {
                            kind: "prev"; size: 14
                            enabled: island.player?.canGoPrevious ?? false
                            onActivated: island.player.previous()
                        }
                        IslandPlayerBtn {
                            kind: island.playing ? "pause" : "play"; size: 16
                            onActivated: island.player?.togglePlaying()
                        }
                        IslandPlayerBtn {
                            kind: "next"; size: 14
                            enabled: island.player?.canGoNext ?? false
                            onActivated: island.player.next()
                        }
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    visible: !island.hasTrack
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDateTime(dateClock.date, "dddd")
                        color: IslandStyle.fg
                        font.family: IslandStyle.font(Font.DemiBold)
                        font.weight: Font.DemiBold
                        font.pixelSize: 12
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDateTime(dateClock.date, "d MMMM")
                        color: IslandStyle.fg2
                        font.family: IslandStyle.fam
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle { Layout.alignment: Qt.AlignVCenter; implicitWidth: 1; implicitHeight: 22; color: IslandStyle.sep }

            IslandStatus { Layout.alignment: Qt.AlignVCenter }
            IslandClock { Layout.alignment: Qt.AlignVCenter }
            IslandBattery { Layout.alignment: Qt.AlignVCenter }
        }

        // ═══════════════════ hub (vertical) ═════════════════
        ColumnLayout {
            id: hubView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 12
            opacity: island.mode === "hub" ? 1 : 0
            visible: opacity > 0.01
            enabled: island.mode === "hub"
            Behavior on opacity { NumberAnimation { duration: IslandStyle.aMed; easing.type: Easing.OutQuad } }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                IslandWorkspaces { monitor: island.hyprMonitor; Layout.alignment: Qt.AlignVCenter }
                Item { Layout.fillWidth: true }
                IslandClock { Layout.alignment: Qt.AlignVCenter }
                IslandBattery { Layout.alignment: Qt.AlignVCenter }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: IslandStyle.sep }

            IslandMedia { Layout.fillWidth: true }

            IslandHub { Layout.fillWidth: true }
        }
    }
}
