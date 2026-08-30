import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../"

// The whole shell in one surface. A centre pill holds workspaces + clock + battery
// (and now-playing when something plays); hovering — or clicking to pin — expands it
// into the full bar with tray, volume, date and transport controls.
PanelWindow {
    id: island

    readonly property int topMargin: 8
    readonly property int maxW: 860
    readonly property int maxH: 54
    readonly property int hubMaxH: 780   // window must be tall enough for the open hub + notifs

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]

    // toggled by shell.qml (Super+H), like the old bar
    property bool shown: true
    visible: Config.data.showIsland && shown

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: hubMaxH + topMargin * 2 + 24   // fixed — surface never resizes
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    mask: Region {
        item: hitArea
    }

    readonly property var c: Appearance.colors
    readonly property var cfg: Config.data

    // ── player ────────────────────────────────────────────
    readonly property var player: {
        const ps = Mpris.players?.values ?? [];
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }
    readonly property bool hasTrack: player != null && (player.trackTitle ?? "") !== ""
    readonly property bool playing: player != null && player.isPlaying

    property bool autoShow: false
    Timer {
        id: autoShowTimer
        interval: 3000
        onTriggered: island.autoShow = false
    }
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

    // ── expand: hover (transient bar) or click (open the hub) ────
    Timer {
        id: lingerTimer
        interval: 350
    }
    property bool hubOpen: false
    // cardHover (a HoverHandler) reports hover over the whole card regardless of which
    // child MouseArea currently has the pointer — no more expand/collapse glitch loop.
    readonly property bool hovered: cardHover.hovered || edgeHover.containsMouse || lingerTimer.running
    readonly property bool expanded: hovered || hubOpen

    // ── hide only for REAL fullscreen, not "maximize" ──
    // Hyprland window .fullscreen field: 0 none · 1 maximize (SUPER+F, keeps gaps) ·
    // 2 fullscreen (SUPER+SHIFT+F, borderless, covers everything) · 3 both.
    // We tuck the island only for 2/3.
    property bool fullscreen: false
    readonly property bool tucked: fullscreen && !hovered && !hubOpen

    // reactive: true whenever the focused workspace has any fullscreen/maximized window
    readonly property bool _hasFs: Hyprland.focusedWorkspace?.hasFullscreen ?? false
    on_HasFsChanged: {
        if (_hasFs)
            fsQuery.running = true;
        else
            // find out which mode it is
            island.fullscreen = false;
    }

    Process {
        id: fsQuery
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            id: fsOut
            onStreamFinished: {
                let mode = 0;
                try {
                    mode = JSON.parse(fsOut.text).fullscreen ?? 0;
                } catch (e) {}
                island.fullscreen = (mode === 2 || mode === 3);
            }
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [island]
        active: island.hubOpen
        property bool settled: false
        onActiveChanged: {
            settled = false;
            if (active)
                settleTimer.restart();
        }
        onCleared: if (grab.settled)
            island.hubOpen = false
    }
    Timer {
        id: settleTimer
        interval: 250
        onTriggered: grab.settled = true
    }
    IpcHandler {
        target: "island"
        function toggle(): void {
            island.hubOpen = !island.hubOpen;
        }
    }

    readonly property bool media: playing || autoShow
    readonly property string mode: hubOpen ? "hub" : (hovered ? "full" : (media && hasTrack ? "compact" : "bar"))

    readonly property int cardW: mode === "hub" ? 468 : mode === "full" ? maxW : mode === "compact" ? 344 : 96
    readonly property int cardH: mode === "hub" ? Math.min(hubMaxH, Math.ceil(hubView.implicitHeight + 24)) : mode === "full" ? maxH : 36
    readonly property int cardR: mode === "hub" ? 28 : mode === "full" ? 24 : 18

    SystemClock {
        id: dateClock
        precision: SystemClock.Minutes
    }

    Timer {
        interval: 1000
        repeat: true
        running: island.mode === "full" && island.playing
        onTriggered: island.player?.positionChanged()
    }

    function fmt(sec) {
        if (!sec || sec < 0)
            sec = 0;
        const m = Math.floor(sec / 60);
        const s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    // media control glyph (MouseArea supplied at the call site)
    component IslandGlyph: Text {
        property string glyph
        property var ma
        property bool dim: false
        property int gsize: 14
        anchors.verticalCenter: parent.verticalCenter
        text: glyph
        font.family: island.cfg.font
        font.pixelSize: gsize
        color: (ma?.containsMouse ?? false) ? island.c.primary : island.c.backgroundFg
        opacity: dim ? 0.35 : 1
        scale: (ma?.pressed ?? false) ? 0.85 : 1
        Behavior on color {
            ColorAnimation {
                duration: Appearance.aFast
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 90
            }
        }
    }

    // fixed hit target -> input mask never recomputed during the morph.
    // shrinks to a thin edge strip while tucked away for fullscreen.
    Item {
        id: hitArea
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: island.tucked ? 520 : (island.mode === "hub" ? 468 : island.maxW)
        height: island.tucked ? 6 : (island.mode === "hub" ? island.hubMaxH : island.maxH) + island.topMargin
    }

    // top-edge hover zone that brings the island back while tucked for fullscreen.
    // only active then — otherwise it's a huge invisible trigger with a gap to the card.
    MouseArea {
        id: edgeHover
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 520
        height: island.topMargin + 8      // overlaps the card's top so there's no dead gap
        hoverEnabled: true
        enabled: island.fullscreen
        onEntered: lingerTimer.stop()
        onExited: lingerTimer.restart()
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: island.tucked ? -(height + 30) : island.topMargin
        opacity: island.tucked ? 0 : 1

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: Appearance.aMed
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.aMed
                easing.type: Easing.OutQuad
            }
        }

        width: island.cardW
        height: island.cardH
        radius: island.cardR
        clip: true

        color: island.c.background
        border.width: 1
        border.color: island.expanded ? Appearance.withAlpha(island.c.primary, 0.30) : Appearance.withAlpha(island.c.outline, 0.14)

        Behavior on width {
            NumberAnimation {
                duration: Appearance.aMed
                easing.type: Easing.OutBack
                easing.overshoot: Appearance.overshoot
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Appearance.aMed
                easing.type: Easing.OutCubic
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: Appearance.aMed
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Appearance.aMed
            }
        }

        MouseArea {
            id: bgMouse
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
            height: 36
            spacing: 9
            opacity: (island.mode === "bar" || barView.compact) ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity {
                NumberAnimation {
                    duration: 90
                    easing.type: Easing.OutQuad
                }
            }

            // centre the clock when there's no media
            Item {
                Layout.fillWidth: true
                visible: island.mode === "bar"
            }

            Art {
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
                color: island.c.backgroundFg
                font.family: island.cfg.fontDisplay
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            // animated sound bars — grow up from a fixed baseline
            Row {
                id: eq
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
                            id: bar
                            readonly property int half: 380 + eqCell.index * 110
                            width: parent.width
                            radius: 1.5
                            color: island.c.primary
                            anchors.bottom: parent.bottom
                            height: 3
                            SequentialAnimation on height {
                                running: island.playing
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 13
                                    duration: bar.half
                                    easing.type: Easing.InOutSine
                                }
                                NumberAnimation {
                                    to: 3
                                    duration: bar.half
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                visible: barView.compact
                implicitWidth: 1
                implicitHeight: 14
                color: Appearance.withAlpha(island.c.surfaceVariantFg, 0.25)
            }

            Clock {
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
                visible: island.mode === "bar"
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
            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.aMed
                    easing.type: Easing.OutQuad
                }
            }

            Workspaces {
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 1
                implicitHeight: 22
                color: Appearance.withAlpha(island.c.surfaceVariantFg, 0.2)
            }

            // centre: media, or the date when nothing is playing
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 12
                    visible: island.hasTrack

                    Art {
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
                            color: island.c.backgroundFg
                            font.family: island.cfg.fontDisplay
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: island.player?.trackArtist ?? ""
                            color: island.c.surfaceVariantFg
                            font.family: island.cfg.fontDisplay
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }
                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 12

                        IslandGlyph {
                            glyph: "\u{f048}"
                            ma: prevMouse
                            dim: !(island.player?.canGoPrevious ?? false)
                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                anchors.margins: -6
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: lingerTimer.stop()
                                onExited: lingerTimer.restart()
                                onClicked: if (island.player?.canGoPrevious)
                                    island.player.previous()
                            }
                        }
                        IslandGlyph {
                            glyph: island.playing ? "\u{f04c}" : "\u{f04b}"
                            ma: playMouse
                            gsize: 15
                            MouseArea {
                                id: playMouse
                                anchors.fill: parent
                                anchors.margins: -6
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: lingerTimer.stop()
                                onExited: lingerTimer.restart()
                                onClicked: island.player?.togglePlaying()
                            }
                        }
                        IslandGlyph {
                            glyph: "\u{f051}"
                            ma: nextMouse
                            dim: !(island.player?.canGoNext ?? false)
                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                anchors.margins: -6
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: lingerTimer.stop()
                                onExited: lingerTimer.restart()
                                onClicked: if (island.player?.canGoNext)
                                    island.player.next()
                            }
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
                        color: island.c.backgroundFg
                        font.family: island.cfg.fontDisplay
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDateTime(dateClock.date, "d MMMM")
                        color: island.c.surfaceVariantFg
                        font.family: island.cfg.fontDisplay
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 1
                implicitHeight: 22
                color: Appearance.withAlpha(island.c.surfaceVariantFg, 0.2)
            }

            StatusItems {
                Layout.alignment: Qt.AlignVCenter
            }
            Clock {
                Layout.alignment: Qt.AlignVCenter
            }
            Battery {
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // ═══════════════════ hub (vertical) ═════════════════
        ColumnLayout {
            id: hubView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12
            opacity: island.mode === "hub" ? 1 : 0
            visible: opacity > 0.01
            enabled: island.mode === "hub"
            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.aMed
                    easing.type: Easing.OutQuad
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Workspaces {
                    Layout.alignment: Qt.AlignVCenter
                }
                Item {
                    Layout.fillWidth: true
                }
                Clock {
                    Layout.alignment: Qt.AlignVCenter
                }
                Battery {
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Appearance.withAlpha(island.c.surfaceVariantFg, 0.15)
            }

            MediaBlock {
                Layout.fillWidth: true
            }

            Hub {
                Layout.fillWidth: true
            }
        }
    }
}
