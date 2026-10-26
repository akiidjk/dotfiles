import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

// Dynamic Island: a black notch hanging from the centre of the menu bar, in place of the workspaces
// (Settings → Menu Bar → Dynamic Island). What it shows, most important first:
//   hover        the player (or the date when nothing is loaded)
//   alert        a passing activity: volume / brightness, notifications, battery, Bluetooth, Wi-Fi, microphone / camera,
//                input source, downloads, workspace switches, `ipc call island notify` (MacBar.islandSay)
//   live         a running screen recording, Clock timer or stopwatch
//   compact      now playing: art, title (or the synced lyric line being sung), sound bars
//   idle         an empty notch
// Privacy dots sit at its right end. Created per screen by MacBar.qml, on its own layer.
PanelWindow {
    id: island

    property var bar: null

    readonly property int collapsedH: (bar ? bar.barHeight : 28) + 5   // hangs a little below the bar: room under the text
    readonly property int ear: 8               // concave fillet joining the notch to the screen edge

    visible: bar !== null && bar.islandShown

    // fixed (the player is the tallest face, the compact lyric line the widest + bump + ears) — surface never resizes.
    // Only as wide as the notch can get: every frame redraws the whole surface, a full-width one cost 4x more.
    anchors.top: true
    implicitWidth: 500
    implicitHeight: 220
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "macisland"
    WlrLayershell.layer: WlrLayer.Top
    mask: Region { item: hitArea }

    readonly property var hyprMonitor: screen ? Hyprland.monitorFor(screen) : null
    readonly property var clock: bar && bar.hub ? bar.hub.clock : null
    readonly property var widgets: bar && bar.hub ? bar.hub.widgets : null

    // ── player ────────────────────────────────────────────
    readonly property var player: {
        const ps = Mpris.players?.values ?? [];
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }
    readonly property bool hasTrack: player != null && (player.trackTitle ?? "") !== ""
    readonly property bool playing: player != null && player.isPlaying

    // synced lyrics come from the widgets' LRCLIB fetch (MacBar asks for them while the island is on)
    readonly property var lyrics: widgets && widgets.lyricsSynced && widgets.player === player ? widgets.lyricsLines : []
    // one line on its own has to be read while it is sung: show it this many seconds early (tuning knob)
    property real lyricLead: 0.4
    readonly property real lyricPos: {
        if (lyrics.length === 0 || !player) return 0;
        // max(): a fresh read lands before nowMs catches up — never count time backwards (or a stale gap forwards)
        if (eng.at > 0) return eng.pos + (playing ? Math.max(0, nowMs - eng.at) / 1000 : 0) + lyricLead;
        return (player.position ?? 0) + lyricLead;
    }

    // Spotifast publishes its MPRIS Position in ~1 s steps, never signals it, and Quickshell only re-reads it on
    // play / pause / track change: the lyrics ran a line behind. Its own CLI answers with the audio engine's position
    // in ms (~6 ms a call), so for Spotifast the lines run off that: re-read whenever the position is asked for
    // (each line's wake-up below), on seeks, play / pause and new lyrics — about once per line.
    readonly property bool spotifast: (player?.dbusName ?? "").endsWith(".spotifast")
    // the last engine read, set in one go (two separate properties made the position jump for a moment in between);
    // at = Date.now() of the read, 0 = none yet (use MPRIS)
    property var eng: ({ pos: 0, at: 0 })
    property real nowMs: Date.now()
    function engineSync() { if (spotifast && lyrics.length > 0) engineProc.running = true; }
    Process {
        id: engineProc
        command: ["spotifast", "now-playing", "--raw"]
        stdout: StdioCollector {
            onStreamFinished: {
                const ms = parseInt(text.split("\t")[4]), t = Date.now();
                if (isNaN(ms)) { island.eng = { pos: 0, at: 0 }; return; }
                const e = island.eng, p = ms / 1000;
                const predicted = e.at > 0 ? e.pos + (island.playing ? (t - e.at) / 1000 : 0) : -1;
                // the engine's own clock moves in ~0.25 s steps: a read taken right at a line change looked "earlier",
                // sent the line back, woke the timer again and bounced every 45 ms. Small differences are that step,
                // not drift — keep the smooth clock and only follow seeks / real drift.
                if (predicted < 0 || Math.abs(p - predicted) > 0.35) {
                    // reads happen right at a line change, so a small step back (drift, not a seek) un-showed the
                    // line just shown and brought it back a moment later — the flash. Hold the clock at that line's start.
                    const i = island.lyricIdx, back = predicted - p;
                    const pos = back > 0 && back < 2 && i >= 0 ? Math.max(p, island.lyrics[i].t - island.lyricLead + 0.001) : p;
                    island.eng = { pos: pos, at: t };
                }
            }
        }
    }
    onLyricsChanged: { eng = { pos: 0, at: 0 }; engineSync(); }
    onPlayingChanged: {
        nowMs = Date.now();
        if (playing && eng.at > 0) eng = { pos: eng.pos, at: nowMs };   // resumed: the pause is not playing time
        engineSync();
    }
    onSpotifastChanged: { eng = { pos: 0, at: 0 }; engineSync(); }
    Connections {
        target: island.player
        ignoreUnknownSignals: true
        function onPositionChanged() { island.engineSync(); }
    }
    readonly property int lyricIdx: {
        const L = lyrics, p = lyricPos;
        let lo = 0, hi = L.length - 1, r = -1;
        while (lo <= hi) {
            const mid = (lo + hi) >> 1;
            if (L[mid].t <= p) { r = mid; lo = mid + 1; } else hi = mid - 1;
        }
        return r;
    }
    readonly property string lyricLine: playing && lyricIdx >= 0 ? lyrics[lyricIdx].text : ""
    // MPRIS does not announce the position (only seeks): instead of polling, wake up when the next line is due,
    // read the position there, and aim again — one wake-up per line
    Timer {
        repeat: true
        running: island.visible && island.playing && island.lyrics.length > 0
        interval: {
            const n = island.lyrics[island.lyricIdx + 1];
            return n ? Math.max(40, Math.round((n.t - island.lyricPos) * 1000) + 15) : 5000;
        }
        onTriggered: { island.nowMs = Date.now(); island.player?.positionChanged(); }
    }

    // a new track: show the compact notch for a while and give it a little bump
    property bool autoShow: false
    property int bump: 0
    Timer { id: autoShowTimer; interval: 3000; onTriggered: island.autoShow = false }
    Timer { id: bumpTimer; interval: 160; onTriggered: island.bump = 0 }
    function kick() { bump = 18; bumpTimer.restart(); }
    Connections {
        target: island.player
        ignoreUnknownSignals: true
        function onTrackTitleChanged() {
            if (!island.playing) return;
            island.autoShow = true;
            autoShowTimer.restart();
            island.kick();
        }
    }

    // ── alert: a passing activity ────────────────────────
    property var act: null
    Timer { id: actTimer; onTriggered: island.act = null }
    function say(a) {
        const fresh = act === null || act.title !== a.title;
        act = a;
        actTimer.interval = a.ms || 2500;
        actTimer.restart();
        if (fresh) kick();
    }
    Connections {
        target: island.bar
        function onIslandAlert(a) { island.say(a); }
    }
    // workspaces left the bar for the island: say which one this screen switched to
    Connections {
        target: island.hyprMonitor
        ignoreUnknownSignals: true
        function onActiveWorkspaceChanged() {
            const ws = island.hyprMonitor.activeWorkspace;
            if (ws && ws.id > 0 && island.bar && island.bar.osdReady)
                island.say({ icon: "\u{f009}", title: "Workspace " + ws.name, ms: 900 });
        }
    }

    // ── live: recording > timer > stopwatch ──────────────
    readonly property string live: bar && bar.recording ? "rec"
                                 : clock && clock.timerActive ? "timer"
                                 : clock && clock.sw.running ? "sw" : ""
    property int tick: 0
    Timer { interval: 500; repeat: true; running: island.visible && island.live !== ""; onTriggered: island.tick++ }
    readonly property string liveTime: {
        tick;
        if (live === "rec") return bar.recTime();
        if (live === "timer") return clock.fmtDur(clock.timer.state === "running" ? Math.max(0, clock.timer.endAt - Date.now()) : clock.timer.left);
        if (live === "sw") return clock.fmtSw(clock.sw.acc + Date.now() - clock.sw.startAt).split(",")[0];
        return "";
    }

    // ── hover ────────────────────────────────────────────
    Timer { id: lingerTimer; interval: 300 }
    readonly property bool hovered: cardHover.hovered || lingerTimer.running

    readonly property bool media: hasTrack && (playing || autoShow)
    readonly property var dots: bar ? bar.privacyDots : []
    readonly property string mode: hovered ? (hasTrack ? "player" : "peek")
                                 : act !== null ? "alert"
                                 : live !== "" ? "live"
                                 : media ? "compact" : "idle"
    readonly property bool actTall: act !== null && ((act.sub ?? "") !== "" || act.value !== undefined)

    readonly property int cardW: (mode === "player" ? 420 : mode === "alert" ? (actTall ? 380 : 260)
                                 : mode === "peek" ? 260 : mode === "live" ? 280
                                 : mode === "compact" ? (lyricLine !== "" ? 440 : 330) : 200) + bump
    readonly property int cardH: mode === "player" ? Math.ceil(playerView.implicitHeight + 30)
                               : mode === "alert" ? (actTall ? 60 : collapsedH + 10)
                               : mode === "peek" ? collapsedH + 14 : collapsedH
    readonly property int cardR: mode === "player" ? 28 : mode === "alert" || mode === "peek" ? 20 : Math.round(collapsedH / 2.4)

    SystemClock { id: dateClock; precision: SystemClock.Minutes }

    // input mask follows the card only
    Item {
        id: hitArea
        x: card.x; y: 0
        width: card.width
        height: card.height
    }

    // ── the notch: black body, flat top, rounded bottom, concave ears into the screen edge ──
    Rectangle {
        x: card.x; y: 0
        width: card.width; height: card.height
        color: "black"
        bottomLeftRadius: card.radius
        bottomRightRadius: card.radius
    }
    Repeater {
        model: 2
        Shape {
            required property int index
            x: index === 0 ? card.x - island.ear : card.x + card.width
            y: 0
            width: island.ear; height: island.ear
            preferredRendererType: Shape.CurveRenderer
            transform: Scale { xScale: index === 0 ? 1 : -1; origin.x: island.ear / 2 }
            ShapePath {
                fillColor: "black"
                strokeColor: "transparent"
                startX: 0; startY: 0
                PathLine { x: island.ear; y: 0 }
                PathLine { x: island.ear; y: island.ear }
                PathArc { x: 0; y: 0; radiusX: island.ear; radiusY: island.ear; direction: PathArc.Counterclockwise }
            }
        }
    }

    // one face of the island: grows in once the notch has started to open, snaps out when it closes
    component Face: Item {
        property bool shown: false
        opacity: shown ? 1 : 0
        scale: shown ? 1 : 0.92
        visible: opacity > 0.01
        enabled: shown
        transformOrigin: Item.Top
        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: shown ? 90 : 0 }
                NumberAnimation { duration: shown ? 220 : 90; easing.type: Easing.OutCubic }
            }
        }
        Behavior on scale { NumberAnimation { duration: 320; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }
    }
    // text that cross-fades when it changes (lyric lines, titles): the old line fades out over the new one fading in
    // (fading to nothing and back blinked like a flash at every line)
    component FadeText: Item {
        id: ft
        property string value
        implicitHeight: cur.implicitHeight
        Component.onCompleted: cur.text = value
        onValueChanged: { old.text = cur.text; cur.text = value; xfade.restart(); }
        Text {
            id: old
            anchors.fill: parent
            opacity: 0
            color: IslandStyle.fg
            font: cur.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            id: cur
            anchors.fill: parent
            color: IslandStyle.fg
            font.family: IslandStyle.font(Font.Medium)
            font.weight: Font.Medium
            font.pixelSize: 12
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        ParallelAnimation {
            id: xfade
            NumberAnimation { target: old; property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { target: cur; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.InOutQuad }
        }
    }
    // privacy dots, at the right end of the small faces
    component Tail: Row {
        spacing: 5
        Repeater {
            model: island.dots
            Rectangle { required property var modelData; anchors.verticalCenter: parent.verticalCenter; width: 6; height: 6; radius: 3; color: modelData }
        }
    }

    Item {
        id: card
        z: 3
        x: Math.round((island.width - width) / 2)
        y: 0
        width: island.cardW
        height: island.cardH
        property real radius: island.cardR
        clip: true

        // springs: the notch overshoots a touch when it opens, like the phone
        Behavior on width { SpringAnimation { spring: 4.5; damping: 0.34; epsilon: 0.3 } }
        Behavior on height { SpringAnimation { spring: 4.5; damping: 0.42; epsilon: 0.3 } }
        Behavior on radius { NumberAnimation { duration: IslandStyle.aMed; easing.type: Easing.OutCubic } }

        // a click dismisses the activity on show
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: island.act = null
        }

        // whole-card hover that child MouseAreas can't steal (blocking:false = passes through)
        HoverHandler {
            id: cardHover
            onHoveredChanged: hovered ? lingerTimer.stop() : lingerTimer.restart()
        }

        // ═══════════ idle / compact: art + title or lyric line + sound bars ═══════════
        Face {
            shown: island.mode === "idle" || island.mode === "compact"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: island.collapsedH

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                IslandArt {
                    size: Math.round(island.collapsedH * 0.62)
                    radius: 5
                    url: island.player?.trackArtUrl ?? ""
                    Layout.alignment: Qt.AlignVCenter
                    visible: island.media
                }
                FadeText {
                    Layout.fillWidth: true
                    visible: island.media
                    value: island.lyricLine !== "" ? island.lyricLine : (island.player?.trackTitle ?? "")
                }
                Item { Layout.fillWidth: true; visible: !island.media }
                IslandEq { running: island.playing; Layout.alignment: Qt.AlignVCenter; visible: island.media }
                Tail { Layout.alignment: Qt.AlignVCenter }
            }
        }

        // ═══════════ live: recording / timer / stopwatch ═══════════
        Face {
            shown: island.mode === "live"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: island.collapsedH

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 8

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    visible: island.live === "rec"
                    implicitWidth: 9; implicitHeight: 9; radius: 4.5
                    color: "#FF453A"
                    SequentialAnimation on opacity {          // the REC dot breathes
                        running: island.mode === "live" && island.live === "rec"   // only while on screen
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1; duration: 700; easing.type: Easing.InOutSine }
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignVCenter
                    visible: island.live !== "rec"
                    text: island.live === "timer" ? "\u{f254}" : "\u{f017}"
                    color: "#FF9F0A"
                    font.family: IslandStyle.iconFont
                    font.pixelSize: 13
                }
                Text {
                    Layout.fillWidth: true
                    text: island.live === "rec" ? "Recording" : island.live === "timer" ? (island.clock?.timer.label || "Timer") : "Stopwatch"
                    color: IslandStyle.fg2
                    font.family: IslandStyle.fam
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: island.liveTime
                    color: island.live === "rec" ? "#FF453A" : "#FF9F0A"
                    font.family: IslandStyle.font(Font.DemiBold)
                    font.weight: Font.DemiBold
                    font.pixelSize: 13
                    font.features: { "tnum": 1 }
                }
                Tail { Layout.alignment: Qt.AlignVCenter }
            }
        }

        // ═══════════ alert: icon or picture, title, subtitle or level ═══════════
        Face {
            shown: island.mode === "alert"
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 16

            RowLayout {
                anchors.fill: parent
                spacing: 11

                Item {
                    id: lead
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: island.actTall ? 34 : 20
                    implicitHeight: implicitWidth
                    readonly property string img: {
                        const s = island.act?.image ?? "";
                        return s !== "" && s[0] === "/" ? "file://" + s : s;
                    }
                    ClippingRectangle {
                        anchors.fill: parent
                        radius: 9
                        color: "transparent"
                        visible: pic.status === Image.Ready
                        Image {
                            id: pic
                            anchors.fill: parent
                            source: lead.img
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(68, 68)
                            asynchronous: true
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: pic.status !== Image.Ready
                        text: island.act?.icon ?? ""
                        color: island.act?.color || IslandStyle.fg
                        font.family: IslandStyle.iconFont
                        font.pixelSize: island.actTall ? 20 : 15
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4
                    Text {
                        Layout.fillWidth: true
                        text: island.act?.title ?? ""
                        color: IslandStyle.fg
                        font.family: IslandStyle.font(Font.DemiBold)
                        font.weight: Font.DemiBold
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: (island.act?.sub ?? "") !== ""
                        text: island.act?.sub ?? ""
                        color: IslandStyle.fg2
                        font.family: IslandStyle.fam
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        textFormat: Text.PlainText
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        visible: island.act?.value !== undefined
                        implicitHeight: 5
                        radius: 2.5
                        color: IslandStyle.track
                        Rectangle {
                            height: parent.height
                            radius: parent.radius
                            width: parent.width * (island.act?.value ?? 0)
                            color: island.act?.color || IslandStyle.fg
                            Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        }
                    }
                }
            }
        }

        // ═══════════ peek (hover, nothing loaded): the date ═══════════
        Face {
            shown: island.mode === "peek"
            anchors.fill: parent
            Text {
                anchors.centerIn: parent
                text: Qt.formatDateTime(dateClock.date, "dddd d MMMM")
                color: IslandStyle.fg
                font.family: IslandStyle.font(Font.DemiBold)
                font.weight: Font.DemiBold
                font.pixelSize: 13
            }
        }

        // ═══════════ player (hover with a track) ═══════════
        Face {
            shown: island.mode === "player"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 14
            height: playerView.implicitHeight
            IslandMedia { id: playerView; anchors.fill: parent }
        }
    }
}
