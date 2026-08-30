import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../"

// Workspace pills — focused one stretches into a wider pill.
RowLayout {
    id: root
    readonly property var c: Appearance.colors
    readonly property var cfg: Config.data

    spacing: Appearance.gapSmall
    visible: cfg.showWorkspaces

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: pill
            required property var modelData
            readonly property bool active: modelData.focused

            Layout.alignment: Qt.AlignVCenter
            implicitWidth: active ? 30 : 20
            implicitHeight: 20
            radius: height / 2
            color: active ? root.c.primary
                          : Appearance.withAlpha(root.c.surfaceFg, hover.containsMouse ? 0.22 : 0.12)

            Behavior on implicitWidth { NumberAnimation { duration: root.cfg.animNormal; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
            Behavior on color { ColorAnimation { duration: root.cfg.animFast } }

            Text {
                anchors.centerIn: parent
                text: pill.modelData.name
                font.pixelSize: 11
                font.family: root.cfg.font
                color: pill.active ? root.c.primaryFg : root.c.surfaceVariantFg
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                anchors.margins: -3        // bigger hit target than the visible pill
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                // Hyprland.dispatch("workspace N") fails on a Lua config — use the model method
                onClicked: pill.modelData.activate()
            }
        }
    }
}
