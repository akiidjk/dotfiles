import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Workspace pills of this island's monitor — the active one stretches into a wider accent pill.
RowLayout {
    id: root
    property var monitor: null      // HyprlandMonitor of the island's screen (null = all workspaces)

    spacing: 6

    Repeater {
        model: root.monitor
            ? Hyprland.workspaces.values.filter(w => w.monitor === root.monitor)
            : Hyprland.workspaces

        delegate: Rectangle {
            id: pill
            required property var modelData
            // .active = focused on its own monitor (per-monitor), unlike .focused (global)
            readonly property bool active: modelData.active

            Layout.alignment: Qt.AlignVCenter
            implicitWidth: active ? 30 : 20
            implicitHeight: 20
            radius: height / 2
            color: active ? IslandStyle.accent : (hover.containsMouse ? IslandStyle.btnOff : IslandStyle.tile)

            Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
            Behavior on color { ColorAnimation { duration: IslandStyle.aFast } }

            Text {
                anchors.centerIn: parent
                text: pill.modelData.name
                font.pixelSize: 11
                font.family: IslandStyle.font(Font.DemiBold)
                font.weight: Font.DemiBold
                color: pill.active ? IslandStyle.accentFg : IslandStyle.fg2
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                anchors.margins: -3
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                // Hyprland.dispatch("workspace N") fails on a Lua config — use the model method
                onClicked: pill.modelData.activate()
            }
        }
    }
}
