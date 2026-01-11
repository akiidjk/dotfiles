//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import "bar" as Bar
import "hub" as Hub
import "wallpicker" as WallPicker
import "keybindings" as Keybindings

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: v
            property var modelData

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

            function toggleHub() {
                hub.visible = !hub.visible;
                if (hub.visible)
                    hub.forceActiveFocus();
            }

            function toggleBar() {
                bar.visible = !bar.visible;
            }

            function toggleWallPicker() {
                wallpicker.visible = !wallpicker.visible;
                if (wallpicker.visible)
                    wallpicker.forceActiveFocus();
            }

            function toggleKeybindings() {
                keybindings.visible = !keybindings.visible;
            // if (keybindings.visible)
            // keybindings.forceActiveFocus();
            }

            Connections {
                target: bar
                function onRequestHubToggle() {
                    toggleHub();
                }
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
