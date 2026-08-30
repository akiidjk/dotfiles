import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import "../"

// Tray + audio — the extras shown only when the island is expanded.
RowLayout {
    id: root
    readonly property var c: Appearance.colors
    readonly property var cfg: Config.data

    spacing: 14

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // ── Tray ──────────────────────────────────────────────
    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 4
        visible: root.cfg.showTray

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: trayItem
                required property var modelData
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 26
                implicitHeight: 26
                radius: 8
                color: tma.containsMouse ? Appearance.withAlpha(root.c.surfaceVariantFg, 0.18) : "transparent"
                Behavior on color { ColorAnimation { duration: root.cfg.animFast } }

                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: trayItem.modelData.icon
                    sourceSize: Qt.size(32, 32)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    id: tma
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        const it = trayItem.modelData;
                        if (mouse.button === Qt.MiddleButton) {
                            it.secondaryActivate();
                        } else if (mouse.button === Qt.RightButton || it.onlyMenu) {
                            if (it.hasMenu)
                                menuAnchor.open();
                        } else {
                            it.activate();
                        }
                    }
                    onWheel: w => trayItem.modelData.scroll(w.angleDelta.y, false)
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.menu
                    anchor.item: trayItem
                    anchor.rect.y: trayItem.height + 6
                    anchor.edges: Qt.BottomEdge
                    anchor.gravity: Qt.BottomEdge
                }
            }
        }
    }

    // ── Audio ── left: pavucontrol · middle: mute · scroll: volume ──
    MouseArea {
        id: audio
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: audioRow.implicitWidth + 12
        implicitHeight: 26
        visible: root.cfg.showAudio && Pipewire.defaultAudioSink !== null
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        readonly property var sink: Pipewire.defaultAudioSink
        readonly property bool muted: sink?.audio?.muted ?? false
        readonly property int vol: Math.round((sink?.audio?.volume ?? 0) * 100)

        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                audio.sink.audio.muted = !audio.sink.audio.muted;
            else
                Quickshell.execDetached(["pavucontrol"]);
        }
        onWheel: w => {
            const a = audio.sink.audio;
            a.volume = Math.max(0, Math.min(1.5, a.volume + (w.angleDelta.y > 0 ? 0.05 : -0.05)));
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: audio.containsMouse ? Appearance.withAlpha(root.c.surfaceVariantFg, 0.18) : "transparent"
            Behavior on color { ColorAnimation { duration: root.cfg.animFast } }
        }

        RowLayout {
            id: audioRow
            anchors.centerIn: parent
            spacing: 5
            Text {
                text: audio.muted ? "\u{f026}" : "\u{f028}"
                font.family: root.cfg.font
                font.pixelSize: 13
                color: audio.muted ? root.c.surfaceVariantFg : root.c.backgroundFg
            }
            Text {
                text: audio.vol + "%"
                font.family: root.cfg.fontDisplay
                font.pixelSize: 12
                font.weight: Font.Medium
                color: audio.muted ? root.c.surfaceVariantFg : root.c.backgroundFg
            }
        }
    }
}
