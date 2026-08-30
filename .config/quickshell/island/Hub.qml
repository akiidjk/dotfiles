import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import "../"

// Vertical control-centre body: sliders, quick toggles, calendar, power.
ColumnLayout {
    id: hub
    readonly property var col: Appearance.colors
    spacing: 12

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }
    readonly property var sink: Pipewire.defaultAudioSink

    // ── brightness (polled) ──
    property real brightness: 0.5
    Process {
        id: briProc
        command: ["sh", "-lc", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        stdout: StdioCollector {
            id: briOut
            onStreamFinished: hub.brightness = Math.max(0, Math.min(1, (parseInt(briOut.text.trim()) || 50) / 100))
        }
    }
    // ── wifi / bt state (polled) ──
    property bool wifiOn: true
    property bool btOn: false
    property bool dnd: false
    Process {
        id: wifiProc
        command: ["sh", "-lc", "nmcli -t -f WIFI g 2>/dev/null | head -n1"]
        stdout: StdioCollector {
            id: wifiOut
            onStreamFinished: hub.wifiOn = wifiOut.text.trim() === "enabled"
        }
    }
    Process {
        id: btProc
        command: ["sh", "-lc", "bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2; exit}'"]
        stdout: StdioCollector {
            id: btOut
            onStreamFinished: hub.btOn = btOut.text.trim() === "yes"
        }
    }
    Timer {
        interval: 3000
        running: hub.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            briProc.running = true;
            wifiProc.running = true;
            btProc.running = true;
        }
    }

    // ── weather (wttr.in, IP-geolocated) ──
    // ponytail: wttr.in free tier, no key. Swap for a keyed API if it rate-limits.
    property string weather: ""
    Process {
        id: wxProc
        command: ["sh", "-lc", "curl -sf --max-time 8 'wttr.in/?format=%t+%C' | sed 's/^+//'"]
        stdout: StdioCollector {
            id: wxOut
            onStreamFinished: {
                const t = wxOut.text.trim();
                if (t)
                    hub.weather = t;
            }
        }
    }
    Timer {
        interval: 1800000            // 30 min
        running: hub.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: wxProc.running = true
    }

    // ═══ sliders ═══
    HSlider {
        Layout.fillWidth: true
        glyph: "\u{f185}"                              // sun
        value: hub.brightness
        onMoved: v => Quickshell.execDetached(["brightnessctl", "set", Math.round(Math.max(5, v * 100)) + "%"])
    }
    HSlider {
        Layout.fillWidth: true
        glyph: "\u{f028}"                              // speaker
        value: hub.sink?.audio?.volume ?? 0
        onMoved: v => {
            if (hub.sink)
                hub.sink.audio.volume = v;
        }
    }

    // ═══ quick toggles ═══
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Toggle {
            glyph: "\u{f1eb}"
            label: "Wi‑Fi"
            on: hub.wifiOn
            onToggled: Quickshell.execDetached(["nmcli", "radio", "wifi", hub.wifiOn ? "off" : "on"])
        }
        Toggle {
            glyph: "\u{f293}"
            label: "Bluetooth"
            on: hub.btOn
            onToggled: Quickshell.execDetached(["bluetoothctl", "power", hub.btOn ? "off" : "on"])
        }
        Toggle {
            glyph: "\u{f1f6}"
            label: "Non disturbare"
            on: hub.dnd
            onToggled: hub.dnd = !hub.dnd
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Appearance.withAlpha(hub.col.surfaceVariantFg, 0.15)
    }

    // ═══ calendar + power ═══
    RowLayout {
        Layout.fillWidth: true
        spacing: 14

        CalendarGrid {
            Layout.alignment: Qt.AlignTop
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 4
            Text {
                text: Qt.formatDateTime(new Date(), "dddd")
                color: hub.col.backgroundFg
                font.family: Config.data.fontDisplay
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            Text {
                text: Qt.formatDateTime(new Date(), "d MMMM yyyy")
                color: hub.col.surfaceVariantFg
                font.family: Config.data.fontDisplay
                font.pixelSize: 11
            }
            RowLayout {
                spacing: 6
                visible: hub.weather !== ""
                Text {
                    text: "\u{f0c2}"                        // cloud
                    font.family: Config.data.font
                    font.pixelSize: 11
                    color: hub.col.primary
                }
                Text {
                    text: hub.weather
                    color: hub.col.backgroundFg
                    font.family: Config.data.fontDisplay
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }
            Item {
                Layout.fillHeight: true
            }
            RowLayout {
                spacing: 8
                PowerBtn {
                    glyph: "\u{f023}"
                    cmd: "loginctl lock-session"
                }
                PowerBtn {
                    glyph: "\u{f2f5}"
                    cmd: "hyprctl dispatch 'hl.dsp.exit()'"   // Lua-config form
                }
                PowerBtn {
                    glyph: "\u{f021}"
                    cmd: "systemctl reboot"
                }
                PowerBtn {
                    glyph: "\u{f011}"
                    cmd: "systemctl poweroff"
                    danger: true
                }
            }
        }
    }

    // ═══ notifications ═══
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Appearance.withAlpha(hub.col.surfaceVariantFg, 0.15)
        visible: notifList.count > 0
    }
    RowLayout {
        Layout.fillWidth: true
        visible: notifList.count > 0
        Text {
            text: "Notification"
            color: hub.col.backgroundFg
            font.family: Config.data.fontDisplay
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
        Item {
            Layout.fillWidth: true
        }
        Text {
            text: "Clear all"
            color: clearMa.containsMouse ? hub.col.primary : hub.col.surfaceVariantFg
            font.family: Config.data.fontDisplay
            font.pixelSize: 10
            MouseArea {
                id: clearMa
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotifService.clearAll()
            }
        }
    }
    ListView {
        id: notifList
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 200)
        visible: count > 0
        clip: true
        spacing: 6
        model: NotifService.model
        boundsBehavior: Flickable.StopAtBounds

        // poll makoctl only while the hub is on screen
        Binding {
            target: NotifService
            property: "active"
            value: hub.visible
        }

        delegate: NotifCard {
            required property int index
            required property int nid
            required property string app
            required property string summary
            width: notifList.width
            appName: app
            summaryText: summary
            onDismissed: NotifService.dismiss(nid, index)
        }
    }

    // ── inline components ─────────────────────────────────
    component HSlider: Item {
        id: sl
        property string glyph
        property real value: 0            // external source of truth (polled / reactive)
        property bool dragging: false
        property real dragValue: 0
        // shown position: follows the pointer instantly while dragging, the source otherwise
        readonly property real display: dragging ? dragValue : value
        signal moved(real v)

        implicitHeight: 26

        // coalesce rapid drag updates so we don't spawn a command every frame
        property real _pending: -1
        Timer {
            id: throttle
            interval: 45
            onTriggered: if (sl._pending >= 0) {
                sl.moved(sl._pending);
                sl._pending = -1;
            }
        }

        Text {
            id: gl
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: sl.glyph
            font.family: Config.data.font
            font.pixelSize: 14
            color: Appearance.colors.backgroundFg
        }
        Rectangle {
            id: trk
            anchors.left: gl.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: 3
            color: Appearance.withAlpha(Appearance.colors.surfaceVariantFg, 0.25)

            Rectangle {
                id: fill
                width: parent.width * Math.max(0, Math.min(1, sl.display))
                height: parent.height
                radius: parent.radius
                color: Appearance.colors.primary
                // smooth catch-up when the poll lands; instant while dragging
                Behavior on width {
                    enabled: !sl.dragging
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutQuad
                    }
                }
            }
            Rectangle {
                width: 13
                height: 13
                radius: 6.5
                color: Appearance.colors.primary
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(trk.width - width, trk.width * sl.display - width / 2))
                Behavior on x {
                    enabled: !sl.dragging
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutQuad
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -10
                preventStealing: true
                function apply(mx) {
                    const v = Math.max(0, Math.min(1, (mx - 10) / trk.width));
                    sl.dragValue = v;
                    sl._pending = v;
                    if (!throttle.running) {
                        sl.moved(v);
                        sl._pending = -1;
                        throttle.start();
                    }
                }
                onPressed: e => {
                    sl.dragging = true;
                    apply(e.x);
                }
                onPositionChanged: e => apply(e.x)
                onReleased: {
                    if (sl._pending >= 0) {
                        sl.moved(sl._pending);
                        sl._pending = -1;
                    }
                    sl.dragging = false;
                }
            }
        }
    }

    component Toggle: Rectangle {
        property string glyph
        property string label
        property bool on: false
        signal toggled
        Layout.fillWidth: true
        implicitHeight: 42
        radius: 13
        color: on ? Appearance.colors.primary : Appearance.withAlpha(Appearance.colors.surfaceVariantFg, tma.containsMouse ? 0.22 : 0.14)
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        readonly property color fg: on ? Appearance.colors.primaryFg : Appearance.colors.backgroundFg
        Column {
            anchors.centerIn: parent
            spacing: 2
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.parent.glyph
                font.family: Config.data.font
                font.pixelSize: 14
                color: parent.parent.fg
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.parent.label
                font.family: Config.data.fontDisplay
                font.pixelSize: 9
                font.weight: Font.Medium
                color: parent.parent.fg
            }
        }
        MouseArea {
            id: tma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.toggled()
        }
    }

    component PowerBtn: Rectangle {
        property string glyph
        property string cmd
        property bool danger: false
        implicitWidth: 34
        implicitHeight: 34
        radius: 17
        readonly property color hi: danger ? Appearance.colors.errorColor : Appearance.colors.primary
        color: pma.containsMouse ? hi : Appearance.withAlpha(Appearance.colors.surfaceVariantFg, 0.14)
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
        Text {
            anchors.centerIn: parent
            text: parent.glyph
            font.family: Config.data.font
            font.pixelSize: 13
            color: pma.containsMouse ? Appearance.colors.background : Appearance.colors.backgroundFg
        }
        MouseArea {
            id: pma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["bash", "-lc", parent.cmd])
        }
    }
}
