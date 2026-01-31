import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

import "../theme.js" as Theme
import "../lib" as Lib
import "../colors.js" as Colors

PanelWindow {
    id: win

    property bool dynamic_island: false
    property bool isDarkMode: true // --- SHARED HEIGHT PARAM ---
    property int itemHeight: win.implicitHeight - 6
    property int activeWsId: Hyprland.focusedMonitor.activeWorkspace.id ?? 1 // -- Volume Widgets Things
    property var defaultAudioSink
    property int volume: 0
    property bool volumeMuted: false // --- THEME ---

    signal requestHubToggle()

    function sh(cmd) {
        return ["bash", "-c", cmd];
    }

    function det(cmd) {
        Quickshell.execDetached(sh(cmd));
    }

    // --- ICON MAP ---
        function getIcon(cls) {
            var c = (cls || "").toLowerCase();
            if (c.includes("firefox") || c.includes("zen") || c.includes("librewolf"))
                return "󰈹";
            if (c.includes("chromium") || c.includes("chrome") || c.includes("thorium"))
                return "";
            if (c.includes("brave"))
                return "";
            if (c.includes("qutebrowser"))
                return "󰖟";
            if (c.includes("kitty"))
                return "󰄛";
            if (c.includes("alacritty") || c.includes("foot") || c.includes("terminal") || c.includes("ghostty") || c.includes("wezterm"))
                return "";
            if (c.includes("code") || c.includes("codium"))
                return "󰨞";
            if (c.includes("sublime"))
                return "󰅳";
            if (c.includes("neovide") || c.includes("nvim"))
                return "";
            if (c.includes("idea") || c.includes("jetbrains"))
                return "";
            if (c.includes("pycharm"))
                return "";
            if (c.includes("webstorm"))
                return "";
            if (c.includes("clion"))
                return "";
            if (c.includes("android"))
                return "󰀴";
            if (c.includes("kate") || c.includes("texteditor"))
                return "󰈔";
            if (c.includes("nautilus") || c.includes("org.gnome.nautilus") || c.includes("files"))
                return "";
            if (c.includes("thunar") || c.includes("dolphin") || c.includes("nemo"))
                return "";
            if (c.includes("discord") || c.includes("vesktop"))
                return "󰙯";
            if (c.includes("slack"))
                return "󰒱";
            if (c.includes("telegram"))
                return "";
            if (c.includes("signal"))
                return "󰭹";
            if (c.includes("element"))
                return "󰘨";
            if (c.includes("whatsapp"))
                return "󰖣";
            if (c.includes("spotify"))
                return "";
            if (c.includes("vlc"))
                return "󰕼";
            if (c.includes("mpv") || c.includes("haruna") || c.includes("strawberry") || c.includes("rhythmbox") || c.includes("totem"))
                return "";
            if (c.includes("gimp"))
                return "";
            if (c.includes("inkscape"))
                return "󰕙";
            if (c.includes("krita"))
                return "";
            if (c.includes("blender"))
                return "󰂫";
            if (c.includes("audacity"))
                return "󰎈";
            if (c.includes("obs"))
                return "";
            if (c.includes("kdenlive"))
                return "󰕧";
            if (c.includes("steam"))
                return "";
            if (c.includes("lutris"))
                return "󰺵";
            if (c.includes("heroic"))
                return "󰊖";
            if (c.includes("prismlauncher"))
                return "󰍳";
            if (c.includes("writer"))
                return "󰈬";
            if (c.includes("calc"))
                return "󰧷";
            if (c.includes("impress"))
                return "󰈧";
            if (c.includes("libreoffice"))
                return "󰈙";
            if (c.includes("evince"))
                return "󰈦";
            if (c.includes("thunderbird"))
                return "";
            if (c.includes("settings") || c.includes("missioncenter"))
                return "";
            if (c.includes("look"))
                return "";
            if (c.includes("systemmonitor"))
                return "󰄨";
            if (c.includes("pavucontrol"))
                return "󰕾";
            if (c.includes("calculator"))
                return "󰃬";
            if (c.includes("weather"))
                return "";
            if (c.includes("evercal"))
                return "󰃭";
            if (c.includes("playing"))
                return "󰎄";
            if (c.includes("photos") || c.includes("org.gnome.loupe") || c.includes("imv") || c.includes("feh") || c.includes("eog") || c.includes("gthumb") || c.includes("qimgv") || c.includes("viewnior"))
                return "";
            if (c.includes("swappy"))
                return "󰫕";
            if (c.includes("zed"))
                return "";
            return "";
    }

    function getDefaultAudioIcon(volume: double) : string {
        // Muted
        // Low volume
        // Medium volume

        if (volume == 0)
            return "";
        else if (volume < 0.33)
            return "";
        else if (volume < 0.66)
            return "";
        else
            return ""; // High volume
    }

    function getMediaIcon(identity: string) : string {
        if (identity == "Spotify")
            return "";
        else if (identity == "YouTube")
            return "";
        else if (identity == "Mozilla zen")
            return "󰈹";
        else
            return ""; // High volume
    }

    implicitHeight: 32
    // implicitWidth: win.dynamic_island ? 850 : undefined
    color: "transparent" // --- GLOBAL STATE --- // Theme mode: default is always dark, false will activate light mode

    margins.top: 10
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: win.implicitHeight - 7
    WlrLayershell.namespace: "shell-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    QtObject {
        id: palette // Backgrounds

        property color bg: win.isDarkMode ? Colors.surface_container : Colors.surface_container_high // Text
        property color textPrimary: win.isDarkMode ? Colors.on_surface : Colors.on_surface
        property color textSecondary: win.isDarkMode ? Colors.on_surface_variant : Colors.on_surface_variant // Accent / primary
        property color accent: win.isDarkMode ? Colors.primary : Colors.primary
        property color activePill: win.isDarkMode ? Colors.primary : Colors.primary // Generic hover/overlay and border
        property color hoverSpotlight: {
            const c = Qt.color(Colors.on_surface);
            return Qt.rgba(c.r, c.g, c.b, win.isDarkMode ? 0.14 : 0.1);
        }
        property color border: win.isDarkMode ? Qt.rgba(Qt.darker(Colors.outline, 1).r, Qt.darker(Colors.outline, 1).g, Qt.darker(Colors.outline, 1).b, 0.8) : Qt.rgba(Qt.darker(Colors.outline, 1).r, Qt.darker(Colors.outline, 1).g, Qt.darker(Colors.outline, 1).b, 0.8) // Workspace hover pill gradient
        property color hoverPillG0: win.isDarkMode ? Qt.rgba(Qt.darker(Colors.primary, 1).r, Qt.darker(Colors.primary, 1).g, Qt.darker(Colors.primary, 1).b, 0.15) : Qt.rgba(Qt.darker(Colors.primary, 1).r, Qt.darker(Colors.primary, 1).g, Qt.darker(Colors.primary, 1).b, 0.14)
        property color hoverPillG1: win.isDarkMode ? Qt.rgba(Qt.darker(Colors.primary_fixed, 1).r, Qt.darker(Colors.primary_fixed, 1).g, Qt.darker(Colors.primary_fixed, 1).b, 0.25) : Qt.rgba(Qt.darker(Colors.primary_fixed, 1).r, Qt.darker(Colors.primary_fixed, 1).g, Qt.darker(Colors.primary_fixed, 1).b, 0.22)
        property color hoverPillG2: win.isDarkMode ? Qt.rgba(Qt.darker(Colors.primary, 1).r, Qt.darker(Colors.primary, 1).g, Qt.darker(Colors.primary, 1).b, 0.15) : Qt.rgba(Qt.darker(Colors.primary, 1).r, Qt.darker(Colors.primary, 1).g, Qt.darker(Colors.primary, 1).b, 0.14)
    }

    // --- HYPRLAND CACHE ---
    QtObject {
        id: hyCache

        property var wsMap: ({
        }) // wsId
        property bool pending: false

        function rebuild() {
            const m = {
            };
            const list = Hyprland.toplevels.values ?? [];
            for (const tl of list) {
                const id = tl?.workspace?.id;
                if (!id)
                    continue;

                if (!m[id])
                    m[id] = [];

                m[id].push(tl);
            }
            wsMap = m;
        }

        function scheduleRebuild() {
            if (pending)
                return ;

            pending = true;
            Qt.callLater(() => {
                pending = false;
                rebuild();
            });
        }

        Component.onCompleted: rebuild()
    }

    // --- POLLERS ---
    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: hyCache.rebuild()
    }

    // Safety Check at 2s
    Timer {
        interval: 2000
        running: true
        repeat: false
        onTriggered: hyCache.rebuild()
    }

    // Event Listener + scheduleRebuild)
    Connections {
        function onRawEvent(ev) {
            if (!ev || !ev.name)
                return ;

            // Check for events
            if (ev.name === "openwindow" || ev.name === "closewindow" || ev.name === "movewindowv2" || ev.name === "workspacev2" || ev.name === "activewindowv2" || ev.name === "urgent") {
                // Re-fetch the window list from Hyprland immediately
                Hyprland.refreshToplevels();
                hyCache.scheduleRebuild();
            }
        }

        target: Hyprland
    }

    Lib.CommandPoll {
        id: powerPoll

        interval: {
            const s = String(batStatus.value ?? "").trim();
            const cap = Number(batCap.value ?? 0);
            if (s === "Discharging" && cap <= 20)
                return 2000;

            return 6000;
        }
        command: ["bash", "-lc", `
												cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
												status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1)
												ac=$(cat /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online 2>/dev/null | head -n1)
												echo "$cap|$status|$ac"
								`]
        parse: function(o) {
            var s = String(o ?? "").trim();
            var p = s.split("|");
            return {
                "cap": Number(p[0]) || 0,
                "status": (p[1] || "").trim(),
                "ac": (p[2] || "").trim()
            };
        }
    }

    QtObject {
        id: batCap

        property var value: (powerPoll.value ? powerPoll.value.cap : 0)
    }

    QtObject {
        id: batStatus

        property var value: (powerPoll.value ? powerPoll.value.status : "")
    }

    QtObject {
        id: acOnline

        property var value: (powerPoll.value ? powerPoll.value.ac : "")
    }

    // --- PIPEWIRE AUDIO TRACKER ---
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Rectangle {
        id: bgRect
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 0

        anchors.leftMargin: 12
        anchors.rightMargin: 12

        color: win.dynamic_island ? Colors.surface_container : "transparent"
        radius: 24
        width: win.dynamic_island ? 850 : (win.width - 24)
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuart
                easing.overshoot: 0.8
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuart
            }
        }

        // 2. WORKSPACES
        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                id: wsContainer

                property int hoveredId: 0
                property var hoveredItem: (wsContainer.hoveredId > 0) ? wsRepeater.itemAt(wsContainer.hoveredId - 1) : null
                property int pressedId: 0
                property var pressedItem: (wsContainer.pressedId > 0) ? wsRepeater.itemAt(wsContainer.pressedId - 1) : null // ACTIVE PILL

                Layout.preferredHeight: win.itemHeight
                Layout.preferredWidth: wsRow.width + 22
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                radius: win.itemHeight / 2
                color: palette.bg
                clip: true

                Rectangle {
                    id: activePill

                    property int currentId: win.activeWsId
                    property var targetItem: wsRepeater.itemAt(activePill.currentId - 1)

                    x: activePill.targetItem ? (wsRow.x + activePill.targetItem.x) : 0
                    width: activePill.targetItem ? activePill.targetItem.width : 0
                    height: win.itemHeight - 12
                    anchors.verticalCenter: parent.verticalCenter
                    radius: (win.itemHeight - 12) / 2
                    color: palette.activePill

                    Behavior on x {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 240
                            easing.type: Easing.OutCubic
                        }

                    }


                }
                // HOVER PILL
                Item {
                    id: hoverPillLayer

                    anchors.fill: parent
                    visible: wsContainer.hoveredId > 0 && wsContainer.hoveredId !== win.activeWsId
                    opacity: hoverPillLayer.visible ? 1 : 0

                    Rectangle {
                        id: hoverPillRect

                        property var t: wsContainer.hoveredItem

                        x: hoverPillRect.t ? (wsRow.x + hoverPillRect.t.x) : 0
                        width: hoverPillRect.t ? hoverPillRect.t.width : 0
                        height: win.itemHeight - 9
                        anchors.verticalCenter: parent.verticalCenter
                        radius: (win.itemHeight - 9) / 2

                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: palette.hoverPillG0
                            }

                            GradientStop {
                                position: 0.45
                                color: palette.hoverPillG1
                            }

                            GradientStop {
                                position: 1
                                color: palette.hoverPillG2
                            }

                        }

                        Behavior on x {
                            NumberAnimation {
                                duration: 260
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.1
                            }

                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 240
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.08
                            }

                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Item {
                    id: pressPillLayer

                    anchors.fill: parent
                    visible: wsContainer.pressedId > 0
                    opacity: pressPillLayer.visible ? 1 : 0

                    Rectangle {
                        id: pressPillRect

                        property var t: wsContainer.pressedItem

                        x: pressPillRect.t ? (wsRow.x + pressPillRect.t.x) : 0
                        width: pressPillRect.t ? pressPillRect.t.width : 0
                        height: win.itemHeight - 9
                        anchors.verticalCenter: parent.verticalCenter
                        radius: (win.itemHeight - 9) / 2
                        color: Qt.rgba(palette.textPrimary.r, palette.textPrimary.g, palette.textPrimary.b, 1)
                        opacity: 0.1

                        Behavior on x {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }

                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 90
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Row {
                    id: wsRow

                    anchors.centerIn: parent
                    spacing: 2

                    Repeater {
                        id: wsRepeater
                        model: 5
                        Item {
                            id: wsDelegate
                            required property int index
                            property int wsId: wsDelegate.index + 1
                            property bool isActive: win.activeWsId === wsDelegate.wsId // --- READ FROM CACHE ---

                            property var wsWindows: hyCache.wsMap[wsDelegate.wsId] ?? []
                            property int winCount: wsDelegate.wsWindows.length
                            property bool hasWindows: wsDelegate.winCount > 0
                            property bool isUrgent: wsDelegate.wsWindows.some(function(tl) {
                                return tl.urgent;
                            })

                            width: wsDelegate.hasWindows ? (wsDelegate.winCount * 22 + 12) : 26
                            height: win.itemHeight

                            y: wsPress.pressed ? 1 : ((!wsDelegate.isActive && wsHover.hovered) ? -2 : 0)
                            scale: (wsPress.pressed ? 0.96 : 1) * ((!wsDelegate.isActive && wsHover.hovered) ? 1.1 : 1)

                            HoverHandler {
                                id: wsHover

                                onHoveredChanged: {
                                    if (hovered)
                                        wsContainer.hoveredId = wsDelegate.wsId;
                                    else if (wsContainer.hoveredId === wsDelegate.wsId)
                                        wsContainer.hoveredId = 0;
                                }
                            }

                            Text {
                                id: wsEmptyIndicator

                                anchors.centerIn: parent
                                visible: !wsDelegate.hasWindows
                                text: "•"
                                font.family: Theme.iconFont
                                font.pixelSize: 14
                                lineHeight: 0.8
                                verticalAlignment: Text.AlignVCenter
                                color: wsDelegate.isActive ? Colors.on_primary : (wsHover.hovered ? Colors.primary : Colors.on_secondary)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 140
                                    }

                                }

                            }

                            Row {
                                id: wsWinRow

                                anchors.centerIn: parent
                                spacing: 0
                                visible: wsDelegate.hasWindows

                                Repeater {
                                    id: wsWinRepeater

                                    model: wsDelegate.wsWindows

                                    Item {
                                        id: wsWinItem

                                        required property var modelData
                                        property string safeClass: {
                                            const o = wsWinItem.modelData.lastIpcObject;
                                            var c = o.class ?? "";
                                            if (!c)
                                                c = o.initialClass ?? "";

                                            if (!c)
                                                c = o.initialTitle ?? "";

                                            if (!c)
                                                c = wsWinItem.modelData.title ?? "";

                                            return String(c);
                                        }

                                        width: 22
                                        height: 22 // --- ipc ---

                                        QtObject {
                                            id: flashColor

                                            property color val: Colors.primary

                                            SequentialAnimation on val {
                                                running: wsWinItem.modelData.urgent
                                                loops: Animation.Infinite

                                                ColorAnimation {
                                                    to: Colors.error
                                                    duration: 200
                                                }

                                                ColorAnimation {
                                                    to: Colors.tertiary
                                                    duration: 200
                                                }

                                            }

                                        }

                                        Text {
                                            id: wsWinText

                                            anchors.centerIn: parent
                                            text: win.getIcon(wsWinItem.safeClass)
                                            font.family: Theme.iconFont
                                            font.pixelSize: 18
                                            lineHeight: 0.8
                                            verticalAlignment: Text.AlignVCenter
                                            scale: (wsDelegate.isActive && wsHover.hovered) ? 1.25 : 1
                                            color: wsDelegate.isActive ? Colors.background : (wsWinItem.modelData.urgent ? flashColor.val : (wsHover.hovered ? Colors.secondary : Colors.on_surface_variant))

                                            Behavior on color {
                                                enabled: !wsWinItem.modelData.urgent

                                                ColorAnimation {
                                                    duration: 140
                                                }

                                            }

                                            Behavior on scale {
                                                NumberAnimation {
                                                    duration: 200
                                                    easing.type: Easing.OutBack
                                                    easing.overshoot: 1.5
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                            MouseArea {
                                id: wsPress

                                anchors.fill: parent
                                hoverEnabled: true
                                onPressed: wsContainer.pressedId = wsDelegate.wsId
                                onReleased: {
                                    if (wsContainer.pressedId === wsDelegate.wsId)
                                        wsContainer.pressedId = 0;

                                }
                                onCanceled: {
                                    if (wsContainer.pressedId === wsDelegate.wsId)
                                        wsContainer.pressedId = 0;

                                }
                                onClicked: win.det("hyprctl dispatch workspace " + wsDelegate.wsId)
                            }

                            Behavior on y {
                                NumberAnimation {
                                    duration: 180
                                    easing.type: Easing.OutCubic
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 220
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.08
                                }

                            }

                        }

                    }

                }

            }

            // 6. BATTERY
            BarItem {
                id: batteryItem
                anchors.verticalCenter: parent.verticalCenter
                property string status: String(batStatus.value).trim()
                property int rawCap: Number(batCap.value) || 0
                property int cap: (batteryItem.rawCap === 0 && batteryItem.status !== "Discharging") ? 50 : batteryItem.rawCap
                property bool plugged: (String(acOnline.value).trim() === "1")
                property bool isCharging: batteryItem.plugged || batteryItem.status === "Charging" || batteryItem.status === "Full"
                property color battColor: {
                    if (batteryItem.isCharging)
                        return palette.accent;

                    if (batteryItem.cap <= 10)
                        return Colors.error;

                    if (batteryItem.cap <= 20)
                        return Colors.tertiary;

                    if (batteryItem.cap <= 30)
                        return Colors.secondary;

                    return palette.textPrimary;
                }
                property string dynamicIcon: {
                    if (batteryItem.isCharging)
                        return "󰂄";

                    if (batteryItem.cap >= 98)
                        return "󰁹";

                    if (batteryItem.cap >= 90)
                        return "󰂂";

                    if (batteryItem.cap >= 80)
                        return "󰂁";

                    if (batteryItem.cap >= 70)
                        return "󰂀";

                    if (batteryItem.cap >= 60)
                        return "󰁿";

                    if (batteryItem.cap >= 50)
                        return "󰁾";

                    if (batteryItem.cap >= 40)
                        return "󰁽";

                    if (batteryItem.cap >= 30)
                        return "󰁼";

                    if (batteryItem.cap >= 20)
                        return "󰁻";

                    return "󰁺";
                }

                Layout.preferredWidth: win.dynamic_island ? 10 : 74
                Layout.preferredHeight: win.itemHeight
                visible: batStatus.value !== ""
                icon: batteryItem.dynamicIcon
                text: batteryItem.cap + "%"
                bgColor: palette.bg
                iconColor: batteryItem.battColor
                textColor: batteryItem.battColor
                borderWidth: 0
                borderColor: "transparent"
                hoverColor: palette.hoverSpotlight
                onPluggedChanged: {
                    if (batteryItem.plugged)
                        surgeAnim.restart();

                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuart
                        easing.overshoot: 0.8
                    }
                }

                SequentialAnimation {
                    running: batteryItem.cap <= 10 && !batteryItem.isCharging
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: batteryItem
                        property: "opacity"
                        to: 0.3
                        duration: 500
                    }

                    NumberAnimation {
                        target: batteryItem
                        property: "opacity"
                        to: 1
                        duration: 500
                    }

                }

                Rectangle {
                    id: powerSurge

                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: parent.height / 2
                    color: "transparent"
                    border.width: 0
                    border.color: "transparent"
                    opacity: 0
                    scale: 1
                }

                ParallelAnimation {
                    id: surgeAnim

                    NumberAnimation {
                        target: powerSurge
                        property: "scale"
                        from: 1
                        to: 1.45
                        duration: 520
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: powerSurge
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 520
                        easing.type: Easing.OutCubic
                    }

                }

            }

            // 3. MEDIA & TITLE
            Item {
                id: mediaItem
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignHCenter
                property MprisPlayer player: Mpris.players.values[0] ?? null
                property bool isPlaying: mediaItem.player && mediaItem.player.playbackState === MprisPlaybackState.Playing
                property string trackTitle: mediaItem.player ? mediaItem.player.trackTitle : ""
                property string trackArtist: mediaItem.player ? mediaItem.player.trackArtist : ""
                anchors.verticalCenter: parent.verticalCenter // Dynamic island

                Rectangle {
                    visible: !mediaItem.isPlaying
                    anchors.centerIn: parent
                    radius: win.itemHeight / 2
                    color: palette.bg
                    implicitWidth: activeTitle.implicitWidth + 24
                    implicitHeight: win.itemHeight

                    Text {
                        id: activeTitle
                        anchors.centerIn: parent
                        text: Hyprland.activeToplevel.title ?? "Desktop"
                        font.family: Theme.iconFont
                        font.weight: 700
                        font.pixelSize: 13
                        color: palette.textPrimary
                        width: Math.min(activeTitle.implicitWidth, win.width / 3.5)
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                Rectangle {
                    visible: mediaItem.isPlaying
                    anchors.centerIn: parent
                    radius: win.itemHeight / 2
                    color: palette.bg
                    implicitHeight: win.itemHeight
                    implicitWidth: mediaRow.implicitWidth + 24

                    RowLayout {
                        id: mediaRow
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: {win.getMediaIcon(mediaItem.player.identity)}
                            font.family: Theme.iconFont
                            font.pixelSize: 14
                            color: palette.accent
                        }

                        Text {
                            text: mediaItem.trackTitle + " <font color='" + palette.textSecondary + "'>- " + mediaItem.trackArtist + "</font>"
                            textFormat: Text.StyledText
                            font.family: Theme.iconFont
                            font.weight: 700
                            font.pixelSize: 13
                            color: palette.textPrimary
                            Layout.maximumWidth: 300
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log(mediaItem.player.togglePlaying());
                    }
                }

            }

            // 5. TRAY
            Rectangle {
                id: trayRect

                visible: SystemTray.items.values.length > 0
                implicitHeight: win.itemHeight
                implicitWidth: (SystemTray.items.values.length * 28) + 12
                radius: win.itemHeight / 2
                color: palette.bg
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: trayRow

                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        id: trayRepeater

                        model: SystemTray.items.values

                        Item {
                            id: trayItem

                            required property SystemTrayItem modelData

                            visible: trayItem.modelData
                            width: 20
                            height: 20
                            scale: trayPress.pressed ? 0.94 : (trayPress.containsMouse ? 1.22 : 1)

                            Image {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: trayItem.modelData.icon
                            }

                            QsMenuAnchor {
                                id: menuAnchor

                                menu: trayItem.modelData.menu

                                anchor {
                                    window: win
                                    item: trayItem
                                }

                            }

                            MouseArea {
                                id: trayPress

                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: {
                                    if (trayItem.modelData.menu) {
                                        console.log("Opening tray menu for", trayItem.modelData.id);
                                        menuAnchor.open();
                                    }
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.08
                                }
                            }

                        }

                    }

                }

            }

            // 5. VOLUME
            BarItem {
                id: volumeItem

                property var audioNode: Pipewire.defaultAudioSink
                property real vol: audioNode.audio.volume

                Layout.preferredWidth: win.dynamic_island ? 10 : 42
                Layout.preferredHeight: win.itemHeight
                anchors.verticalCenter: parent.verticalCenter
                visible: SystemTray.items.values.length > 0
                icon: win.getDefaultAudioIcon(vol) // text: Math.round(vol * 100) + "%"
                bgColor: palette.bg
                iconColor: batteryItem.battColor
                textColor: batteryItem.battColor
                borderColor: "transparent"
                hoverColor: palette.hoverSpotlight

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuart
                        easing.overshoot: 0.8
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        win.det("pactl set-sink-mute @DEFAULT_SINK@ toggle");
                    }
                    onWheel: {
                        if (wheel.angleDelta.y > 0)
                            win.det("pactl set-sink-volume @DEFAULT_SINK@ +5%");
                        else if (wheel.angleDelta.y < 0)
                            win.det("pactl set-sink-volume @DEFAULT_SINK@ -5%");
                    }
                }


            }

            // 7. CLOCK
            Rectangle {
                id: clockRect

                Layout.preferredHeight: win.itemHeight
                Layout.preferredWidth: clockRow.implicitWidth + 30
                anchors.verticalCenter: parent.verticalCenter
                radius: win.itemHeight / 2
                color: palette.bg
                clip: true
                scale: clockArea.pressed ? 0.98 : (clockArea.containsMouse ? 1.02 : 1)

                RowLayout {
                    id: clockRow

                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        id: dateText

                        text: Qt.formatDateTime(new Date(), "ddd, MMM d")
                        font.family: Theme.textFont
                        font.pixelSize: 12
                        font.weight: 600
                        color: palette.accent
                    }

                    Text {
                        text: "•"
                        font.pixelSize: 10
                        color: palette.textSecondary
                    }

                    Text {
                        id: timeText

                        text: Qt.formatDateTime(new Date(), "h:mm AP")
                        font.family: Theme.textFont
                        font.pixelSize: 13
                        font.weight: 800
                        color: palette.textPrimary
                    }

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            var now = new Date();
                            dateText.text = Qt.formatDateTime(now, "ddd, MMM d");
                            timeText.text = Qt.formatDateTime(now, "h:mm AP");
                        }
                    }

                }

                Rectangle {
                    id: clockMask

                    anchors.fill: parent
                    radius: win.itemHeight / 2
                    visible: false
                }

                Item {
                    id: clockMaskLayer

                    anchors.fill: parent
                    layer.enabled: true
                    layer.smooth: true

                    Rectangle {
                        id: clockShimmer

                        width: 44
                        height: parent.height * 2
                        rotation: 20
                        x: -100
                        y: -parent.height / 2
                        color: "transparent"

                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: "transparent"
                            }

                            GradientStop {
                                position: 0.5
                                color: win.isDarkMode ? Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.2) : Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.1)
                            }

                            GradientStop {
                                position: 1
                                color: "transparent"
                            }

                        }

                    }

                    layer.effect: OpacityMask {
                        maskSource: clockMask
                    }

                }

                NumberAnimation {
                    id: clockShimmerAnim

                    target: clockShimmer
                    property: "x"
                    from: -60
                    to: clockRect.width + 60
                    duration: 800
                    easing.type: Easing.InOutQuad
                }

                MouseArea {
                    id: clockArea

                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: (mouse) => {
                        win.requestHubToggle();
                        mouse.accepted = true;
                    }
                    onEntered: clockShimmerAnim.restart()
                }

                Rectangle {
                    anchors.fill: parent
                    radius: win.itemHeight / 2
                    color: win.isDarkMode ? Colors.on_surface : Colors.on_surface
                    opacity: clockArea.pressed ? 0.18 : (clockArea.containsMouse ? 0.12 : 0)

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Rectangle {
                    anchors.fill: parent
                    radius: win.itemHeight / 2
                    color: "transparent"
                    border.width: 0
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.05
                    }

                }

            }

        }

    }

}
