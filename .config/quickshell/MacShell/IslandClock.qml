import Quickshell
import QtQuick

Text {
    property string format: (IslandStyle.bar && !IslandStyle.bar.use24h) ? "h:mm AP" : "HH:mm"
    SystemClock { id: c; precision: SystemClock.Minutes }
    text: Qt.formatDateTime(c.date, format)
    font.family: IslandStyle.font(Font.DemiBold)
    font.pixelSize: 12
    font.weight: Font.DemiBold
    color: IslandStyle.fg
}
