import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../colors.js" as Colors

PanelWindow {
    id: root

    implicitWidth: 600
    implicitHeight: 700
    color: "transparent"
    focusable: true

    // --- DATA HANDLING ---
    property var allBinds: [] // Raw data storage

        function refreshList() {
            var query = searchField.text.toLowerCase();
            bindModel.clear();

            for (var i = 0; i < allBinds.length; i++) {
                var item = allBinds[i];

                // Skip empty keys if necessary
                if (!item.key) continue;

                // Prepare strings for comparison
                var mods = root.getModsArray(item.modmask).join(" ").toLowerCase();
                var key = (item.key || "").toLowerCase();
                var dispatcher = (item.dispatcher || "").toLowerCase();
                var arg = (item.arg || "").toLowerCase();

                // Check if any field matches the search query
                if (key.includes(query) || dispatcher.includes(query) || arg.includes(query) || mods.includes(query)) {
                    bindModel.append(item);
                }
            }
        }

    // ---------------------------------------------------------
    // 1. SYMBOL & MAP LOGIC (Adapted from Target Code)
    // ---------------------------------------------------------

    property var symbolMap: ({
        "Super": "",
        "Ctrl": "󰘴",
        "Alt": "󰘵",
        "Shift": "󰘶",
        "Enter": "󰌑",
        "Return": "󰌑",
        "Space": "󱁐",
        "Tab": "↹",
        "BackSpace": "󰭜",
        "Delete": "⌦",
        "Escape": "⎋",
        "Up": "↑",
        "Down": "↓",
        "Left": "←",
        "Right": "→",
        "mouse_up": "󱕐",
        "mouse_down": "󱕑",
    })

    // Helper to get symbol or fallback to text
    function getSymbol(keyName) {
        return symbolMap[keyName] || keyName;
    }

    function getModsArray(modmask) {
        let mods = [];
        if (modmask === 64) mods.push("Super");
        else if (modmask === 65) { mods.push("Super"); mods.push("Shift"); }
        else if (modmask === 1)  mods.push("Shift");
        else if (modmask === 4)  mods.push("Ctrl");
        else if (modmask === 5)  { mods.push("Ctrl"); mods.push("Shift"); }
        else if (modmask === 8)  mods.push("Alt");
        return mods;
    }

    // ---------------------------------------------------------
    // 2. REUSABLE UI COMPONENTS
    // ---------------------------------------------------------

    component KeyCap: Rectangle {
        property string label: ""
        property bool isMod: false

        color: isMod ? Colors.secondary_container : Colors.surface_container_highest
        height: 28
        width: keyText.implicitWidth + 16 // Padding
        radius: 6
        border.width: 1
        border.color: Colors.outline_variant

        Text {
            id: keyText
            anchors.centerIn: parent
            text: root.getSymbol(parent.label)
            font.pixelSize: 14
            font.bold: true
            color: isMod ? Colors.on_secondary_container : Colors.on_surface
        }
    }

    // ---------------------------------------------------------
    // 3. MAIN LAYOUT
    // ---------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color: Colors.background

        // --- CHANGE RADIUS HERE ---
        radius: 20

        // Optional: Add a border if you want the panel to pop more
        border.color: Colors.outline_variant
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Header
            Text {
                text: "Keybinds"
                font.pixelSize: 28
                font.weight: Font.Light
                color: Colors.primary
                Layout.alignment: Qt.AlignLeft
            }

            // Search Bar styled with Matugen
            TextField {
                id: searchField
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                placeholderText: "Search command or key..."
                placeholderTextColor: Colors.on_surface_variant
                color: Colors.on_surface
                font.pixelSize: 14
                leftPadding: 12

                background: Rectangle {
                    color: Colors.surface_container
                    radius: 12
                    border.color: searchField.activeFocus ? Colors.primary : Colors.outline
                    border.width: searchField.activeFocus ? 2 : 1
                }

                // Clear button
                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    visible: searchField.text.length > 0
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: "✕"
                        font.pixelSize: 14
                        color: Colors.on_surface_variant
                    }
                    onClicked: {
                        searchField.text = "";
                    }
                }

                onTextChanged: root.refreshList()
            }

            // List Container
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }

                ListView {
                    id: keybindListView
                    width: parent.width
                    spacing: 8
                    model: ListModel { id: bindModel }

                    delegate: Rectangle {
                        property int bind_modmask: (typeof modmask !== "undefined") ? modmask : 0

                        width: keybindListView.width
                        height: 50
                        color: Colors.surface_container_low
                        radius: 8

                        // Hover effect (optional)
                        border.color: Colors.outline_variant
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            // 1. Modifiers (Repeater for Super, Shift, etc.)
                            Row {
                                spacing: 4
                                Repeater {
                                    model: root.getModsArray(bind_modmask)
                                    delegate: KeyCap {
                                        label: modelData
                                        isMod: true
                                    }
                                }
                            }

                            // Plus sign if mods exist
                            Text {
                                visible: model.modmask > 0 && model.key !== ""
                                text: "+"
                                color: Colors.outline
                                font.pixelSize: 14
                            }

                            // 2. The Main Key
                            KeyCap {
                                visible: model.key !== ""
                                label: model.key
                                isMod: false
                            }

                            // Spacer
                            Item { Layout.fillWidth: true }

                            // 3. Dispatcher / Command info
                            ColumnLayout {
                                spacing: 0
                                Layout.alignment: Qt.AlignRight

                                Text {
                                    text: model.dispatcher
                                    color: Colors.primary
                                    font.pixelSize: 13
                                    font.bold: true
                                    Layout.alignment: Qt.AlignRight
                                }

                                Text {
                                    text: model.arg
                                    color: Colors.on_surface_variant
                                    font.pixelSize: 11
                                    elide: Text.ElideLeft
                                    visible: model.arg !== ""
                                    Layout.maximumWidth: 200
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------
    // 4. DATA FETCHING
    // ---------------------------------------------------------

    // --- DATA LOADING ---
        Process {
            id: hyprProc
            running: true
            command: ["hyprctl", "binds", "-j"]
            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        const binds = JSON.parse(this.text);
                        root.allBinds = binds; // Save raw data
                        root.refreshList();    // Populate view
                        console.log("Loaded " + binds.length + " keybinds.");
                    } catch(e) {
                        console.error("Error parsing hyprctl JSON: " + e);
                    }
                }
            }
    }
}
