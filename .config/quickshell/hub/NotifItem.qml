import QtQuick
import QtQuick.Layouts
import "../theme.js" as Theme
import "../lib" as Lib
import "../colors.js" as Colors

Rectangle {
    id: root
    property int nId: 0
    property string app: "SYSTEM"
    property string summary: "Notification"
    property QtObject theme: null
    readonly property bool hasTheme: theme !== null
    readonly property bool isDarkMode: (!hasTheme || (theme.isDarkMode === undefined)) ? true : theme.isDarkMode

    readonly property color cBg: isDarkMode ? Colors.surface_container : Colors.surface_container_high
    readonly property color cBgHover: Colors.surface_container_highest
    readonly property color cSheen: Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.06)
    readonly property color cRipple: Qt.rgba(Colors.surface_tint.r, Colors.surface_tint.g, Colors.surface_tint.b, 0.16)
    readonly property color cIconBg: Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.05)
    readonly property color cAccent: Colors.primary
    readonly property color cFgMuted: Colors.on_surface_variant
    readonly property color cFgMain: Colors.on_surface

    signal clicked()

    radius: 16
    color: hovered ? cBgHover : cBg
    antialiasing: true
    border.width: 1
    border.color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.6)

    property bool hovered: false

    // subtle lift on hover
    scale: pressed ? 0.985 : (hovered ? 1.01 : 1.0)
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 140 } }

    // tiny highlight
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: cSheen
        opacity: hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140 } }
    }

    // ripple
    Lib.Ripple {
        id: ripple
        rippleColor: cRipple
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Rectangle {
            width: 30
            height: 30
            radius: 999
            color: cIconBg
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "󰋽"
                text: "\U000F03FD"
                font.family: Theme.iconFont
                font.pixelSize: 15
                font.weight: 900
                color: cAccent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: String(root.app).toUpperCase()
                font.family: Theme.textFont
                font.pixelSize: 9
                font.weight: 900
                color: cFgMuted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.summary
                font.family: Theme.textFont
                font.pixelSize: 12
                font.weight: 800
                color: cFgMain
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    property bool pressed: false

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: root.hovered = true
        onExited: root.hovered = false

        onPressed: { root.pressed = true; ripple.burst(mouse.x, mouse.y) }
        onReleased: root.pressed = false

        onClicked: root.clicked()
    }
}
