//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "island" as Island
import "keybindings" as Keybindings
import "wallpicker" as WallPicker

ShellRoot {
    id: root

    Variants {
        id: islands
        model: Quickshell.screens

        Island.Island {
            required property var modelData
            screen: modelData
        }
    }

    function focusedIsland() {
        for (let i = 0; i < islands.instances.length; i++) {
            const candidate = islands.instances[i];
            if (candidate.screen?.name === Hyprland.focusedMonitor?.name)
                return candidate;
        }
        return islands.instances[0] ?? null;
    }

    function toggleHub() {
        const island = focusedIsland();
        if (island)
            island.hubOpen = !island.hubOpen;
    }

    IpcHandler {
        target: "island"
        function toggle(): void { root.toggleHub(); }
        function toggleDebug(): void {
            for (let i = 0; i < islands.instances.length; i++)
                islands.instances[i].debugLayers = !islands.instances[i].debugLayers;
        }
    }

    WallPicker.WallPicker {
        id: wallpicker
        visible: false
    }

    Keybindings.Keybindings {
        id: keybindings
        visible: false
    }

    // Super+H — show / hide the island (replaces the old bar toggle)
    GlobalShortcut {
        name: "barToggle"
        description: "Toggle island"
        onPressed: {
            let shown = false;
            for (let i = 0; i < islands.instances.length; i++) {
                if (islands.instances[i].shown)
                    shown = true;
            }
            for (let i = 0; i < islands.instances.length; i++)
                islands.instances[i].shown = !shown;
        }
    }

    // Super+N — open / close the island's control centre (replaces the old hub)
    GlobalShortcut {
        name: "hubToggle"
        description: "Toggle island hub"
        onPressed: root.toggleHub()
    }

    GlobalShortcut {
        name: "wallPickerToggle"
        description: "Toggle wallpaper picker"
        onPressed: {
            wallpicker.visible = !wallpicker.visible;
            if (wallpicker.visible)
                wallpicker.forceActiveFocus();
        }
    }

    GlobalShortcut {
        name: "keybindingsToggle"
        description: "Toggle keybindings overlay"
        onPressed: keybindings.visible = !keybindings.visible
    }
}
