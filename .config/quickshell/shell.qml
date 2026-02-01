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

    Variants {
        id: variants
        model: Quickshell.screens

        Scope {

            // if (keybindings.visible)
            // keybindings.forceActiveFocus();

            id: v
            property bool dynamic_island: false
            property var modelData

            function toggleHub() {
                hub.visible = !hub.visible;
                if (hub.visible)
                    hub.forceActiveFocus();
            }

            function toggleBar() {
                bar.visible = !bar.visible;
            }

            function changeLayout() {
                v.dynamic_island = !v.dynamic_island;
            }

            function toggleWallPicker() {
                wallpicker.visible = !wallpicker.visible;
                if (wallpicker.visible)
                    wallpicker.forceActiveFocus();
            }

            function toggleKeybindings() {
                keybindings.visible = !keybindings.visible;
            }

            Hub.HubWindow {
                id: hub

                visible: false
            }

            WallPicker.WallPicker {
                id: wallpicker

                visible: false
            }

            Bar.Bar {
                id: bar
                screen: v.modelData
            }

            Keybindings.Keybindings {
                id: keybindings

                visible: false
            }

            Connections {
                function onRequestHubToggle() {
                    toggleHub();
                }

                target: bar
            }

            GlobalShortcut {
                name: "hubToggle"
                description: "Toggle hub"
                onPressed: toggleHub()
            }

            GlobalShortcut {
                name: "barToggle"
                description: "Toggle bar"
                onPressed: toggleBar()
            }

            GlobalShortcut {
                name: "changeBarLayout"
                description: "Change bar layout"
                onPressed: changeLayout()
            }

            GlobalShortcut {
                name: "wallPickerToggle"
                description: "Toggle wallpaper picker"
                onPressed: toggleWallPicker()
            }

            GlobalShortcut {
                name: "keybindingsToggle"
                description: "Toggle keybindings overlay"
                onPressed: toggleKeybindings()
            }
        }
    }
}
