import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Keybindings overlay (Super+K, Help → Hyprland Keybinds): every `hyprctl binds -j` entry, searchable.
// Created per screen by MacBar.qml; only the focused screen shows it. The Liquid Glass slab is handed in by MacBar as a
// child (lands behind the panel), like Island.qml.
PanelWindow {
    id: kb

    property var bar: null
    property Component backdrop: null
    property bool focusedScreen: true
    default property alias glass: glassHost.data
    readonly property Item backdropItem: bdLoader.item
    readonly property bool shown: bar !== null && bar.keybindsOpen && focusedScreen

    readonly property real panelX: panel.x
    readonly property real panelY: panel.y
    readonly property real panelW: panel.width
    readonly property real panelH: panel.height
    readonly property real panelR: 28

    visible: shown || panel.opacity > 0
    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "macbinds"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onVisibleChanged: if (bar) bar.popCount += (visible ? 1 : -1)     // keeps the window-geometry poller running
    onShownChanged: if (shown) { search.text = ""; bindsProc.running = true; search.forceActiveFocus(); }

    // ── data ──
    property var allBinds: []
    ListModel { id: bindModel }
    // macOS key symbols; anything else shows its own name
    readonly property var symbols: ({
        "Super": "⌘", "Ctrl": "⌃", "Alt": "⌥", "Shift": "⇧",
        "RETURN": "↩", "Return": "↩", "Enter": "↩", "SPACE": "Space", "space": "Space",
        "TAB": "⇥", "Tab": "⇥", "BackSpace": "⌫", "Delete": "⌦", "Escape": "⎋",
        "up": "↑", "down": "↓", "left": "←", "right": "→",
        "Up": "↑", "Down": "↓", "Left": "←", "Right": "→",
        "mouse:272": "Left Click", "mouse:273": "Right Click", "mouse_up": "Scroll ↑", "mouse_down": "Scroll ↓",
        "comma": ",", "period": ".", "PRINT": "Print", "Print": "Print"
    })
    function sym(k) { return symbols[k] || k; }
    // Hyprland modmask bits: SHIFT 1, CAPS 2, CTRL 4, ALT 8, MOD2 16, MOD3 32, SUPER 64, MOD5 128
    function mods(mask) {
        var m = [];
        if (mask & 64) m.push("Super");
        if (mask & 4) m.push("Ctrl");
        if (mask & 8) m.push("Alt");
        if (mask & 1) m.push("Shift");
        return m;
    }
    function label(b) {
        if (b.description) return b.description;
        return ((b.dispatcher || "") + " " + (b.arg || "")).trim();
    }
    function refresh() {
        var q = search.text.toLowerCase();
        bindModel.clear();
        for (var i = 0; i < allBinds.length; i++) {
            var b = allBinds[i];
            if (!b.key) continue;
            var ms = mods(b.modmask || 0);
            var hay = (ms.join(" ") + " " + b.key + " " + label(b)).toLowerCase();
            if (q === "" || hay.indexOf(q) >= 0)
                bindModel.append({ mods: ms.join(","), key: b.key, text: label(b) });
        }
    }
    Process {
        id: bindsProc
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { kb.allBinds = JSON.parse(text); } catch (e) { console.warn("[keybinds] bad hyprctl json:", e); kb.allBinds = []; }
                kb.refresh();
            }
        }
    }

    Loader {
        id: bdLoader
        active: kb.bar !== null && kb.bar.liquidActive && kb.backdrop !== null
        sourceComponent: kb.backdrop
        onLoaded: {
            item.hostShown = Qt.binding(function () { return kb.visible; });
            item.region = Qt.binding(function () { return Qt.rect(panel.x - 96, panel.y - 96, panel.width + 192, panel.height + 192); });
        }
    }

    MouseArea { anchors.fill: parent; onPressed: kb.bar.keybindsOpen = false }      // click outside closes

    Item {
        id: panel
        z: 10
        width: Math.min(640, kb.width - 120)
        height: Math.min(720, kb.height - 160)
        x: Math.round((kb.width - width) / 2)
        y: Math.round((kb.height - height) / 2)
        opacity: kb.shown ? 1 : 0
        visible: opacity > 0
        scale: kb.shown ? 1 : 0.96
        transformOrigin: Item.Center
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Item { id: glassHost; anchors.fill: parent }
        MenuBorder {
            z: 2
            anchors.fill: parent
            cornerR: kb.panelR
            dark: IslandStyle.theme.dark
            tint: kb.bar ? kb.bar.menuBorderColor : "#8A9AB5"
        }
        MouseArea { anchors.fill: parent }     // clicks inside stay inside

        Keys.onEscapePressed: event => { if (search.text !== "") search.text = ""; else kb.bar.keybindsOpen = false; event.accepted = true; }

        ColumnLayout {
            z: 3
            anchors.fill: parent
            anchors.margins: 22
            anchors.topMargin: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Keybindings"
                    color: IslandStyle.theme.fg
                    font.family: IslandStyle.font(Font.DemiBold)
                    font.weight: Font.DemiBold
                    font.pixelSize: 15
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: bindModel.count + " binds"
                    color: IslandStyle.theme.fg3
                    font.family: IslandStyle.fam
                    font.pixelSize: 11
                }
            }

            // search field (Spotlight-like)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 10
                color: IslandStyle.theme.tile
                border.width: 1
                border.color: search.activeFocus ? IslandStyle.accent : IslandStyle.theme.tileBorder
                TextInput {
                    id: search
                    anchors.fill: parent
                    anchors.leftMargin: 12; anchors.rightMargin: 30
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    color: IslandStyle.theme.fg
                    selectionColor: IslandStyle.accent
                    font.family: IslandStyle.fam
                    font.pixelSize: 13
                    onTextChanged: kb.refresh()
                    Keys.onEscapePressed: event => { if (text !== "") text = ""; else kb.bar.keybindsOpen = false; event.accepted = true; }
                    Keys.onDownPressed: list.flick(0, -800)
                    Keys.onUpPressed: list.flick(0, 800)
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: search.text === ""
                        text: "Search key or command…"
                        color: IslandStyle.theme.fg3
                        font: search.font
                    }
                }
                Text {
                    anchors.right: parent.right; anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    visible: search.text !== ""
                    text: "✕"
                    color: clearMa.containsMouse ? IslandStyle.theme.fg : IslandStyle.theme.fg3
                    font.pixelSize: 12
                    MouseArea { id: clearMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; onClicked: search.text = "" }
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: bindModel
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: row
                    required property string mods
                    required property string key
                    required property string text
                    width: list.width
                    height: 40
                    radius: 10
                    color: rowMa.containsMouse ? IslandStyle.theme.hover : IslandStyle.theme.tile
                    Behavior on color { ColorAnimation { duration: IslandStyle.aFast } }
                    MouseArea { id: rowMa; anchors.fill: parent; hoverEnabled: true }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10; anchors.rightMargin: 12
                        spacing: 4
                        Repeater {
                            model: row.mods === "" ? [] : row.mods.split(",")
                            delegate: KeyCap { required property string modelData; label: kb.sym(modelData); isMod: true }
                        }
                        KeyCap { label: kb.sym(row.key) }
                        Item { Layout.fillWidth: true }
                        Text {
                            Layout.maximumWidth: list.width * 0.55
                            text: row.text
                            color: IslandStyle.theme.fg
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight
                            font.family: IslandStyle.fam
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }

    component KeyCap: Rectangle {
        property string label: ""
        property bool isMod: false
        Layout.alignment: Qt.AlignVCenter
        implicitHeight: 24
        implicitWidth: Math.max(24, capText.implicitWidth + 14)
        radius: 6
        color: isMod ? IslandStyle.theme.btnOff : IslandStyle.alpha(IslandStyle.accent, 0.22)
        border.width: 1
        border.color: IslandStyle.theme.tileBorder
        Text {
            id: capText
            anchors.centerIn: parent
            text: parent.label
            color: IslandStyle.theme.fg
            font.family: IslandStyle.font(Font.DemiBold)
            font.weight: Font.DemiBold
            font.pixelSize: 12
        }
    }
}
