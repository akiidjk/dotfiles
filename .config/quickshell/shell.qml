//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import "bar" as Bar
import "hub" as Hub

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

            Bar.Bar {
                id: bar
                screen: v.modelData
            }

            function toggleHub() {
                hub.visible = !hub.visible;
                if (hub.visible)
                    hub.forceActiveFocus();
            }

            function toggleBar() {
                bar.visible = !bar.visible;
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
        }
    }
}
