import Quickshell
import QtQuick
import "../"

Text {
    property string format: Config.data.clockFormat
    SystemClock { id: c; precision: SystemClock.Minutes }
    text: Qt.formatDateTime(c.date, format)
    font.family: Config.data.fontDisplay
    font.pixelSize: 12
    font.weight: Font.Medium
    color: Appearance.colors.backgroundFg
}
