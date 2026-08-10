//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "bar" as Bar
import "hub" as Hub
import "keybindings" as Keybindings
import "wallpicker" as WallPicker

ShellRoot {
    id: root

    property bool barsVisible: true

    function toggleHub() {
        hub.visible = !hub.visible;
        if (hub.visible)
            hub.forceActiveFocus();
    }

    function toggleWallPicker() {
        wallpicker.visible = !wallpicker.visible;
        if (wallpicker.visible)
            wallpicker.forceActiveFocus();
    }

    function toggleKeybindings() {
        keybindings.visible = !keybindings.visible;
    }

    function changeLayout() {
        var current = (layoutFile.text() || "").trim();
        var next = current === "true" ? "false" : "true";
        layoutFile.setText(next);
    }

    FileView {
        id: layoutFile
        path: Qt.resolvedUrl("./.current_layout")
    }

    Hub.HubWindow {
        id: hub
        visible: false
    }

    WallPicker.WallPicker {
        id: wallpicker
        visible: false
    }

    Keybindings.Keybindings {
        id: keybindings
        visible: false
    }

    GlobalShortcut {
        name: "hubToggle"
        description: "Toggle hub"
        onPressed: root.toggleHub()
    }

    GlobalShortcut {
        name: "barToggle"
        description: "Toggle bar"
        onPressed: root.barsVisible = !root.barsVisible
    }

    GlobalShortcut {
        name: "changeBarLayout"
        description: "Change bar layout"
        onPressed: root.changeLayout()
    }

    GlobalShortcut {
        name: "wallPickerToggle"
        description: "Toggle wallpaper picker"
        onPressed: root.toggleWallPicker()
    }

    GlobalShortcut {
        name: "keybindingsToggle"
        description: "Toggle keybindings overlay"
        onPressed: root.toggleKeybindings()
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: v
            property var modelData

            Bar.Bar {
                id: bar
                screen: v.modelData
                visible: root.barsVisible

                Connections {
                    target: bar
                    function onRequestHubToggle() {
                        root.toggleHub();
                    }
                }
            }
        }
    }
}
