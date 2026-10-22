import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

// Tray + audio — the extras shown only when the island is expanded. Audio goes through MacBar (same OSD / sounds).
RowLayout {
    id: root
    readonly property var bar: IslandStyle.bar

    spacing: 14

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 4
        visible: root.bar ? root.bar.showTray : true

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: trayItem
                required property var modelData
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 26
                implicitHeight: 26
                radius: 8
                color: tma.containsMouse ? IslandStyle.hover : "transparent"
                Behavior on color { ColorAnimation { duration: IslandStyle.aFast } }

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
        visible: root.bar !== null && root.bar.sink !== null
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        readonly property bool muted: root.bar ? root.bar.muted : false
        readonly property int vol: Math.round((root.bar ? root.bar.volume : 0) * 100)

        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) root.bar.hwMute();
            else Quickshell.execDetached(["pavucontrol"]);
        }
        onWheel: w => root.bar.hwVolume(w.angleDelta.y > 0 ? 0.05 : -0.05)

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: audio.containsMouse ? IslandStyle.hover : "transparent"
            Behavior on color { ColorAnimation { duration: IslandStyle.aFast } }
        }

        RowLayout {
            id: audioRow
            anchors.centerIn: parent
            spacing: 5
            Text {
                text: audio.muted ? "\u{f026}" : "\u{f028}"
                font.family: IslandStyle.iconFont
                font.pixelSize: 13
                color: audio.muted ? IslandStyle.fg3 : IslandStyle.fg
            }
            Text {
                text: audio.vol + "%"
                font.family: IslandStyle.font(Font.Medium)
                font.weight: Font.Medium
                font.pixelSize: 12
                color: audio.muted ? IslandStyle.fg3 : IslandStyle.fg
            }
        }
    }
}
