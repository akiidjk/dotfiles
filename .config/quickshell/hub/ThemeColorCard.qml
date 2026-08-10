import QtQuick
import QtQuick.Layouts
import Quickshell
import "../lib" as Lib
import "../theme.js" as Theme
import "../colors.js" as Colors

Lib.Card {
    id: root
    Layout.fillWidth: true
    property bool active: true

    readonly property bool themed: root.theme !== null
    readonly property color textPrimary: themed ? root.theme.textPrimary : Colors.on_surface
    readonly property color textSecondary: themed ? root.theme.textSecondary : Colors.on_surface_variant
    readonly property color bgItem: themed ? root.theme.bgItem : Colors.surface_container_low
    readonly property color outline: themed ? root.theme.outline : Colors.outline_variant

    readonly property color initialColor: Colors.source_color
    property real hue: initialColor.hsvHue >= 0 ? initialColor.hsvHue : 0
    property real sat: initialColor.hsvSaturation
    property real val: initialColor.hsvValue

    readonly property color currentColor: Qt.hsva(root.hue, root.sat, root.val, 1)

    // "applying" reflects a command currently in flight
    property bool applying: false
    property string lastAppliedHex: ""

    Component.onCompleted: {
        lastAppliedHex = root.colorToHex(root.currentColor);
    }

    function sh(cmd) {
        return ["bash", "-lc", cmd];
    }

    function toHex2(v) {
        var h = Math.round(Math.max(0, Math.min(1, v)) * 255).toString(16);
        return h.length < 2 ? "0" + h : h;
    }

    function colorToHex(c) {
        return "#" + toHex2(c.r) + toHex2(c.g) + toHex2(c.b);
    }

    function commit() {
        console.log("Committing color: " + root.colorToHex(root.currentColor));
        var hex = root.colorToHex(root.currentColor);
        console.log("Hex: " + hex + ", lastAppliedHex: " + root.lastAppliedHex + ", applying: " + root.applying);

        if (hex === root.lastAppliedHex && !root.applying) {
            console.log("Color unchanged, skipping commit.");
            return;
        }
        if (root.applying) {
            console.log("Command already in flight, scheduling commit after delay.");
            commitTimer.restart();
            return;
        }

        root.lastAppliedHex = hex;
        root.applying = true;
        applyResetTimer.restart();
        console.log("Executing command: matugen color hex \"" + hex + "\" -m dark --continue-on-error");
        Quickshell.execDetached(sh("matugen color hex \"" + hex + "\" -m dark --fallback-color=#000000 --continue-on-error"));
    }

    function scheduleCommit() {
        commitTimer.restart();
    }

    function commitNow() {
        commitTimer.stop();
        dragPauseTimer.stop();
        root.commit();
    }

    function applyHex(hexStr) {
        if (!hexStr)
            return;
        var h = String(hexStr).trim().toLowerCase();
        if (h.charAt(0) !== '#')
            h = '#' + h;
        if (/^#[0-9a-f]{3}$/.test(h)) {
            h = '#' + h[1] + h[1] + h[2] + h[2] + h[3] + h[3];
        }
        if (!/^#[0-9a-f]{6}$/.test(h))
            return;

        var c = Qt.color(h);
        if (c.hsvHue >= 0) {
            root.hue = c.hsvHue;
        }
        root.sat = c.hsvSaturation;
        root.val = c.hsvValue;

        if (hexInput.text.toLowerCase() !== h) {
            hexInput.text = h;
        }

        root.commitNow();
    }

    // Reset applying status after a timeout
    Timer {
        id: applyResetTimer
        interval: 1000
        repeat: false
        onTriggered: root.applying = false
    }

    // Delay timer for scheduled commit
    Timer {
        id: commitTimer
        interval: 350
        repeat: false
        onTriggered: root.commit()
    }

    // Timer triggered when cursor movement stops in picker
    Timer {
        id: dragPauseTimer
        interval: 350
        repeat: false
        onTriggered: root.commit()
    }

    readonly property var presets: ["#F44336", "#FF9800", "#FFEB3B", "#4CAF50", "#009688", "#2196F3", "#3F51B5", "#9C27B0", "#E91E63", "#795548"]

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Theme Color"
                font.family: Theme.textFont
                font.pixelSize: 13
                font.weight: 900
                color: root.textPrimary
                Layout.fillWidth: true
            }

            Text {
                text: root.applying ? "Applying…" : ""
                font.family: Theme.textFont
                font.pixelSize: 10
                font.italic: true
                color: root.textSecondary
            }
        }

        // --- Saturation / Value square ---
        Item {
            id: svSquare
            Layout.fillWidth: true
            implicitHeight: 130
            clip: true

            function updateFromPos(x, y) {
                var cx = Math.max(0, Math.min(width, x));
                var cy = Math.max(0, Math.min(height, y));
                root.sat = width > 0 ? cx / width : 0;
                root.val = height > 0 ? 1 - (cy / height) : 0;
            }

            Rectangle {
                id: svBase
                anchors.fill: parent
                radius: Theme.radiusInner
                color: Qt.hsva(root.hue, 1, 1, 1)
            }

            // Saturation: white -> transparent (left to right)
            Rectangle {
                anchors.fill: svBase
                radius: svBase.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: "#ffffffff"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#00ffffff"
                    }
                }
            }

            // Value: transparent -> black (top to bottom)
            Rectangle {
                anchors.fill: svBase
                radius: svBase.radius
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#00000000"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#ff000000"
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: svBase.radius
                color: "transparent"
                border.width: 1
                border.color: root.outline
            }

            // Handle
            Rectangle {
                id: svHandle
                width: 16
                height: 16
                radius: 8
                x: Math.max(0, Math.min(svSquare.width - width, root.sat * svSquare.width - width / 2))
                y: Math.max(0, Math.min(svSquare.height - height, (1 - root.val) * svSquare.height - height / 2))
                color: root.currentColor
                border.width: 2
                border.color: "white"

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(0, 0, 0, 0.35)
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.CrossCursor
                onPressed: mouse => {
                    commitTimer.stop();
                    svSquare.updateFromPos(mouse.x, mouse.y);
                    dragPauseTimer.restart();
                }
                onPositionChanged: mouse => {
                    if (pressed) {
                        svSquare.updateFromPos(mouse.x, mouse.y);
                        dragPauseTimer.restart();
                    }
                }
                onReleased: root.commitNow()
                onCanceled: root.commitNow()
            }
        }

        // --- Hue slider ---
        Item {
            id: hueSlider
            Layout.fillWidth: true
            implicitHeight: 22
            clip: true

            function updateFromPos(x) {
                var cx = Math.max(0, Math.min(width, x));
                root.hue = width > 0 ? cx / width : 0;
            }

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                border.width: 1
                border.color: root.outline
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: "#ff0000"
                    }
                    GradientStop {
                        position: 0.166
                        color: "#ffff00"
                    }
                    GradientStop {
                        position: 0.333
                        color: "#00ff00"
                    }
                    GradientStop {
                        position: 0.5
                        color: "#00ffff"
                    }
                    GradientStop {
                        position: 0.666
                        color: "#0000ff"
                    }
                    GradientStop {
                        position: 0.833
                        color: "#ff00ff"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#ff0000"
                    }
                }
            }

            Rectangle {
                id: hueHandle
                width: 16
                height: hueSlider.height - 4
                radius: height / 2
                x: Math.max(0, Math.min(hueSlider.width - width, root.hue * hueSlider.width - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                border.width: 3
                border.color: "white"

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(0, 0, 0, 0.35)
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => {
                    commitTimer.stop();
                    hueSlider.updateFromPos(mouse.x);
                    dragPauseTimer.restart();
                }
                onPositionChanged: mouse => {
                    if (pressed) {
                        hueSlider.updateFromPos(mouse.x);
                        dragPauseTimer.restart();
                    }
                }
                onReleased: root.commitNow()
                onCanceled: root.commitNow()
            }
        }

        // --- Preview + hex input ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: root.currentColor
                border.width: 2
                border.color: root.outline
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: Theme.radiusInner
                color: root.bgItem
                border.width: hexInput.activeFocus ? 1 : 0
                border.color: hexInput.activeFocus ? (root.themed ? root.theme.primary : Colors.primary) : root.outline

                TextInput {
                    id: hexInput
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.textPrimary
                    font.family: Theme.textFont
                    font.pixelSize: 12
                    selectByMouse: true
                    maximumLength: 7

                    Component.onCompleted: text = root.colorToHex(root.currentColor)

                    onAccepted: {
                        root.applyHex(text);
                    }
                    onActiveFocusChanged: {
                        if (!activeFocus)
                            text = root.colorToHex(root.currentColor);
                    }

                    Connections {
                        target: root
                        function onCurrentColorChanged() {
                            if (!hexInput.activeFocus)
                                hexInput.text = root.colorToHex(root.currentColor);
                        }
                    }
                }
            }
        }

        // --- Presets ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.presets

                delegate: Item {
                    Layout.fillWidth: true
                    implicitHeight: 24

                    readonly property string presetColor: modelData.toLowerCase()
                    readonly property bool isSelected: root.colorToHex(root.currentColor).toLowerCase() === presetColor

                    Rectangle {
                        id: swatch
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        radius: 10
                        color: modelData
                        border.width: isSelected ? 2 : 1
                        border.color: isSelected ? "#ffffff" : root.outline
                        scale: swatchMouse.pressed ? 0.85 : (swatchMouse.containsMouse ? 1.15 : 1.0)

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutBack
                            }
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: "#ffffff"
                            visible: isSelected
                        }

                        MouseArea {
                            id: swatchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyHex(modelData)
                        }
                    }
                }
            }
        }
    }
}
