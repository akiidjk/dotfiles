import QtQuick
import QtQuick.Layouts

// Month grid, today highlighted with the accent. Week start follows MacShell's "weekStartsMonday".
Item {
    id: root
    property date when: new Date()
    property var cells: []
    readonly property bool monday: IslandStyle.bar ? IslandStyle.bar.weekStartsMonday : true

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    function rebuild() {
        const d = root.when;
        const y = d.getFullYear();
        const m = d.getMonth();
        const today = d.getDate();
        const shift = root.monday ? 1 : 0;
        const firstDay = (new Date(y, m, 1).getDay() - shift + 7) % 7;
        const daysInMonth = new Date(y, m + 1, 0).getDate();
        const heads = root.monday ? ["M", "T", "W", "T", "F", "S", "S"] : ["S", "M", "T", "W", "T", "F", "S"];

        const out = [];
        for (let i = 0; i < 7; i++) out.push({ kind: "head", t: heads[i] });
        for (let i = 0; i < firstDay; i++) out.push({ kind: "blank", t: "" });
        for (let i = 1; i <= daysInMonth; i++) out.push({ kind: "day", t: String(i), today: i === today });
        root.cells = out;
    }
    Component.onCompleted: rebuild()
    onWhenChanged: rebuild()
    onMondayChanged: rebuild()

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
                    width: 18; height: 18; radius: 9
                    visible: parent.cell.today === true
                    color: IslandStyle.accent
                }
                Text {
                    anchors.centerIn: parent
                    text: parent.cell.t
                    readonly property int w: parent.cell.kind === "head" || parent.cell.today ? Font.DemiBold : Font.Normal
                    font.family: IslandStyle.font(w)
                    font.weight: w
                    font.pixelSize: parent.cell.kind === "head" ? 9 : 10
                    color: parent.cell.kind === "head" ? IslandStyle.fg3 : (parent.cell.today ? IslandStyle.accentFg : IslandStyle.fg)
                }
            }
        }
    }
}
