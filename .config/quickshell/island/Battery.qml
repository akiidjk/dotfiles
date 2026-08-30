import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../"

RowLayout {
    id: root
    spacing: 5
    visible: Config.data.showBattery && UPower.displayDevice.isLaptopBattery

    readonly property var dev: UPower.displayDevice
    // ponytail: UPower.percentage reads 0..1 here; guard covers builds that report 0..100
    readonly property int pct: dev.percentage <= 1 ? Math.round(dev.percentage * 100)
                                                   : Math.round(dev.percentage)
    readonly property bool charging: dev.state === UPowerDeviceState.Charging
                                     || dev.state === UPowerDeviceState.FullyCharged
    readonly property bool low: pct <= 20 && !charging
    readonly property color tint: low ? Appearance.colors.errorColor : Appearance.colors.backgroundFg

    Text {
        text: root.charging
              ? "\u{f0e7}"
              : ["\u{f244}", "\u{f243}", "\u{f242}", "\u{f241}", "\u{f240}"][Math.min(4, Math.floor(root.pct / 20))]
        font.family: Config.data.font
        font.pixelSize: 13
        color: root.tint
    }
    Text {
        text: root.pct + "%"
        font.family: Config.data.fontDisplay
        font.pixelSize: 12
        font.weight: Font.Medium
        color: root.tint
    }
}
