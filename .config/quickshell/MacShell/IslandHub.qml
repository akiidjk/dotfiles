import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Island hub body: sliders, quick toggles, calendar, power, notifications.
// Every value / action is MacBar's own (the same state the Control Center uses), so nothing is polled twice.
ColumnLayout {
    id: hub
    readonly property var bar: IslandStyle.bar
    spacing: 12

    // ── weather (wttr.in, IP-geolocated) ──
    // ponytail: wttr.in free tier, no key. Swap for MacShell's open-meteo weather widget data if it rate-limits.
    property string weather: ""
    Process {
        id: wxProc
        command: ["sh", "-c", "curl -sf --max-time 8 'wttr.in/?format=%t+%C' | sed 's/^+//'"]
        stdout: StdioCollector {
            onStreamFinished: { const t = text.trim(); if (t) hub.weather = t; }
        }
    }
    Timer {
        interval: 1800000            // 30 min
        running: hub.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: wxProc.running = true
    }

    // ═══ sliders (MacShell's Control Center slider) ═══
    HubSlider {
        glyph: "\u{f185}"                              // sun
        value: hub.bar ? hub.bar.brightness : 0
        onMoved: v => hub.bar.setBrightness(v)
    }
    HubSlider {
        glyph: (hub.bar && hub.bar.muted) ? "\u{f026}" : "\u{f028}"
        value: hub.bar ? (hub.bar.muted ? 0 : hub.bar.volume) : 0
        onMoved: v => hub.bar.setVolume(v)
    }

    // ═══ quick toggles ═══
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Toggle {
            glyph: "\u{f1eb}"
            label: "Wi‑Fi"
            on: hub.bar ? hub.bar.wifiOn : false
            onToggled: hub.bar.toggleWifi()
        }
        Toggle {
            glyph: "\u{f293}"
            label: "Bluetooth"
            on: hub.bar ? hub.bar.btOn : false
            onToggled: hub.bar.toggleBt()
        }
        Toggle {
            glyph: "\u{f1f6}"
            label: "Non disturbare"
            on: hub.bar ? hub.bar.notifDnd : false
            onToggled: hub.bar.notifDnd = !hub.bar.notifDnd
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: IslandStyle.sep }

    // ═══ calendar + power ═══
    RowLayout {
        Layout.fillWidth: true
        spacing: 14

        IslandCalendar { Layout.alignment: Qt.AlignTop }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 4
            Text {
                text: Qt.formatDateTime(new Date(), "dddd")
                color: IslandStyle.fg
                font.family: IslandStyle.font(Font.DemiBold)
                font.weight: Font.DemiBold
                font.pixelSize: 15
            }
            Text {
                text: Qt.formatDateTime(new Date(), "d MMMM yyyy")
                color: IslandStyle.fg2
                font.family: IslandStyle.fam
                font.pixelSize: 11
            }
            RowLayout {
                spacing: 6
                visible: hub.weather !== ""
                Text {
                    text: "\u{f0c2}"                        // cloud
                    font.family: IslandStyle.iconFont
                    font.pixelSize: 11
                    color: IslandStyle.accent
                }
                Text {
                    text: hub.weather
                    color: IslandStyle.fg
                    font.family: IslandStyle.font(Font.Medium)
                    font.weight: Font.Medium
                    font.pixelSize: 11
                }
            }
            Item { Layout.fillHeight: true }
            RowLayout {
                spacing: 8
                PowerBtn { glyph: "\u{f023}"; onActivated: hub.bar.lockScreen() }
                PowerBtn { glyph: "\u{f2f5}"; onActivated: hub.bar.logOut() }
                PowerBtn { glyph: "\u{f021}"; onActivated: Quickshell.execDetached(["systemctl", "reboot"]) }
                PowerBtn { glyph: "\u{f011}"; danger: true; onActivated: Quickshell.execDetached(["systemctl", "poweroff"]) }
            }
        }
    }

    // ═══ notifications (MacShell's notification history) ═══
    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: IslandStyle.sep; visible: notifList.count > 0 }
    RowLayout {
        Layout.fillWidth: true
        visible: notifList.count > 0
        Text {
            text: "Notifications"
            color: IslandStyle.fg
            font.family: IslandStyle.font(Font.DemiBold)
            font.weight: Font.DemiBold
            font.pixelSize: 12
        }
        Item { Layout.fillWidth: true }
        Text {
            text: "Clear all"
            color: clearMa.containsMouse ? IslandStyle.accent : IslandStyle.fg2
            font.family: IslandStyle.fam
            font.pixelSize: 10
            MouseArea {
                id: clearMa
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: hub.bar.notifClear()
            }
        }
    }
    ListView {
        id: notifList
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 220)
        visible: count > 0
        clip: true
        spacing: 6
        model: hub.bar ? hub.bar.notifHistory : null
        boundsBehavior: Flickable.StopAtBounds

        delegate: IslandNotif {
            required property int nid
            required property string app
            required property string summary
            required property string body
            required property string icon
            width: notifList.width
            appName: app
            summaryText: summary
            bodyText: body
            iconSource: icon
            onDismissed: hub.bar.notifDelete(nid)
        }
    }

    // ── inline components ─────────────────────────────────
    component HubSlider: Item {
        id: sl
        property string glyph
        property real value: 0
        signal moved(real v)
        Layout.fillWidth: true
        implicitHeight: 26

        Text {
            id: gl
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            horizontalAlignment: Text.AlignHCenter
            text: sl.glyph
            font.family: IslandStyle.iconFont
            font.pixelSize: 14
            color: IslandStyle.fg
        }
        GlassSlider {
            anchors.left: gl.right
            anchors.leftMargin: 6
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            value: sl.value
            decimals: 2
            onMoved: v => sl.moved(v)
            fg: IslandStyle.fg
            trackColor: IslandStyle.track
            labelColor: IslandStyle.fg2
            fontFamily: IslandStyle.fam
            dark: IslandStyle.dark
            baseColor: IslandStyle.dark ? "#2B2B2D" : "#FFFFFF"
            glass: hub.bar ? hub.bar.liquidActive : false
            shaderUrl: hub.bar ? hub.bar.glassShaderUrl : ""
            glassLiquid: hub.bar ? hub.bar.glassLiquid : 1
            glassRim: hub.bar ? hub.bar.glassRim : 0.45
            glassGrain: hub.bar ? hub.bar.glassGrain : 0.03
            glassTint: hub.bar ? hub.bar.glassOpacity : 0.42
            borderTint: hub.bar ? hub.bar.menuBorderColor : "#8A9AB5"
        }
    }

    // Control Center style toggle: round icon that turns accent when on, label under it
    component Toggle: Rectangle {
        id: tg
        property string glyph
        property string label
        property bool on: false
        signal toggled
        Layout.fillWidth: true
        implicitHeight: 64
        radius: 18
        color: tma.containsMouse ? IslandStyle.hover : IslandStyle.tile
        border.width: 1
        border.color: IslandStyle.tileBorder
        Behavior on color { ColorAnimation { duration: IslandStyle.aFast } }
        scale: tma.pressed ? 0.97 : 1
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2.4 } }

        Column {
            anchors.centerIn: parent
            spacing: 4
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 30; height: 30; radius: 15
                color: tg.on ? IslandStyle.accent : IslandStyle.btnOff
                Behavior on color { ColorAnimation { duration: 200 } }
                Text {
                    anchors.centerIn: parent
                    text: tg.glyph
                    font.family: IslandStyle.iconFont
                    font.pixelSize: 13
                    color: tg.on ? IslandStyle.accentFg : IslandStyle.fg
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tg.label
                font.family: IslandStyle.font(Font.Medium)
                font.weight: Font.Medium
                font.pixelSize: 10
                color: IslandStyle.fg
            }
        }
        MouseArea {
            id: tma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tg.toggled()
        }
    }

    component PowerBtn: Rectangle {
        id: pb
        property string glyph
        property bool danger: false
        signal activated
        implicitWidth: 34
        implicitHeight: 34
        radius: 17
        readonly property color hi: danger ? IslandStyle.danger : IslandStyle.accent
        color: pma.containsMouse ? hi : IslandStyle.tile
        border.width: 1
        border.color: IslandStyle.tileBorder
        Behavior on color { ColorAnimation { duration: 120 } }
        Text {
            anchors.centerIn: parent
            text: pb.glyph
            font.family: IslandStyle.iconFont
            font.pixelSize: 13
            color: pma.containsMouse ? IslandStyle.accentFg : IslandStyle.fg
        }
        MouseArea {
            id: pma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pb.activated()
        }
    }
}
