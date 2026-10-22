import Quickshell
import QtQuick
import QtQuick.Layouts

// One row in the hub's notification list (MacShell notification history). Click to dismiss.
Rectangle {
    id: card
    property string appName: ""
    property string summaryText: ""
    property string bodyText: ""
    property string iconSource: ""
    signal dismissed

    implicitHeight: 50
    radius: 14
    color: ma.containsMouse ? IslandStyle.hover : IslandStyle.tile
    border.width: 1
    border.color: IslandStyle.tileBorder
    Behavior on color { ColorAnimation { duration: IslandStyle.aFast } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 10

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 30; implicitHeight: 30
            radius: 8
            color: IslandStyle.alpha(IslandStyle.accent, 0.18)
            Image {
                id: ico
                anchors.fill: parent
                anchors.margins: 3
                source: card.iconSource
                sourceSize: Qt.size(48, 48)
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: !ico.visible
                text: "\u{f0f3}"
                font.family: IslandStyle.iconFont
                font.pixelSize: 12
                color: IslandStyle.accent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1
            Text {
                Layout.fillWidth: true
                visible: card.appName !== ""
                text: card.appName
                color: IslandStyle.fg2
                font.family: IslandStyle.font(Font.DemiBold)
                font.weight: Font.DemiBold
                font.pixelSize: 9
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: card.summaryText
                color: IslandStyle.fg
                font.family: IslandStyle.font(Font.DemiBold)
                font.weight: Font.DemiBold
                font.pixelSize: 12
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: card.bodyText !== ""
                text: card.bodyText
                color: IslandStyle.fg2
                font.family: IslandStyle.fam
                font.pixelSize: 11
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.dismissed()
    }
}
