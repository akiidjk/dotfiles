import QtQuick
import QtQuick.Layouts
import "../"

// Month grid, today highlighted. Adapted from ~/.config/quickshell/hub/CalendarGrid.qml.
Item {
    id: root
    property date when: new Date()
    property var cells: []

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    function rebuild() {
        const d = root.when;
        const y = d.getFullYear();
        const m = d.getMonth();
        const today = d.getDate();
        const firstDay = new Date(y, m, 1).getDay();
        const daysInMonth = new Date(y, m + 1, 0).getDate();
        const heads = ["S", "M", "T", "W", "T", "F", "S"];

        const out = [];
        for (let i = 0; i < 7; i++) out.push({ kind: "head", t: heads[i] });
        for (let i = 0; i < firstDay; i++) out.push({ kind: "blank", t: "" });
        for (let i = 1; i <= daysInMonth; i++) out.push({ kind: "day", t: String(i), today: i === today });
        root.cells = out;
    }
    Component.onCompleted: rebuild()
    onWhenChanged: rebuild()

    GridLayout {
        id: grid
        columns: 7
        rowSpacing: 4
        columnSpacing: 4

        Repeater {
            model: root.cells.length
            delegate: Item {
                required property int index
                readonly property var cell: root.cells[index]
                Layout.preferredWidth: 20
                Layout.preferredHeight: 18

                Rectangle {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    radius: 6
                    visible: parent.cell.today === true
                    color: Appearance.colors.primary
                }
                Text {
                    anchors.centerIn: parent
                    text: parent.cell.t
                    font.family: Config.data.fontDisplay
                    font.pixelSize: parent.cell.kind === "head" ? 9 : 10
                    font.weight: parent.cell.kind === "head" ? Font.Normal
                                 : (parent.cell.today ? Font.Bold : Font.Normal)
                    color: parent.cell.kind === "head" ? Appearance.colors.surfaceVariantFg
                           : (parent.cell.today ? Appearance.colors.primaryFg : Appearance.colors.backgroundFg)
                }
            }
        }
    }
}
