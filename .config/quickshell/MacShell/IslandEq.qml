import QtQuick

// sound bars: each one swings up and down on its own sine (the original 0.76–1.42 s periods), sampled `fps` times a
// second instead of at the display's refresh rate.
// ponytail: a free-running Qt animation kept the island redrawing at 60+ fps (~13% CPU with music on); sampling the same
// motion costs `fps` frames a second. Raise it if the bars ever look choppy.
Row {
    id: eq
    property bool running: false
    property int fps: 24
    property real t: 0                      // seconds since the bars started moving
    spacing: 2

    Timer {
        interval: Math.round(1000 / eq.fps)
        repeat: true
        running: eq.running && eq.visible       // hidden face: nothing ticks
        onTriggered: eq.t += interval / 1000
        onRunningChanged: if (!running) eq.t = 0
    }

    Repeater {
        model: 4
        Item {
            id: eqCell
            required property int index
            readonly property real period: 0.76 + index * 0.22
            width: 3
            height: 14
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 3 + 10 * (0.5 - 0.5 * Math.cos(2 * Math.PI * eq.t / eqCell.period))
                radius: 1.5
                color: IslandStyle.accent
            }
        }
    }
}
