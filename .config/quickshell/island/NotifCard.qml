import QtQuick
import QtQuick.Layouts
import "../"

// One row in the hub's notification list. Click to dismiss.
Rectangle {
    id: card
    property string appName: ""
    property string summaryText: ""
    signal dismissed

    readonly property var col: Appearance.colors

    implicitHeight: 46
    radius: 12
    color: Appearance.withAlpha(col.surfaceContainerHigh, 0.92)
    border.width: 1
    border.color: Appearance.withAlpha(col.outline, 0.12)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 10

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 28
            implicitHeight: 28
            radius: 8
            color: Appearance.withAlpha(card.col.primary, 0.16)
            Text {
                anchors.centerIn: parent
                text: "\u{f0f3}"
                font.family: Config.data.font
                font.pixelSize: 12
                color: card.col.primary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1
            Text {
                Layout.fillWidth: true
                visible: card.appName !== ""
                text: card.appName.toUpperCase()
                color: card.col.surfaceVariantFg
                font.family: Config.data.fontDisplay
                font.pixelSize: 8
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: card.summaryText
                color: card.col.backgroundFg
                font.family: Config.data.fontDisplay
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: card.dismissed()
    }
}
