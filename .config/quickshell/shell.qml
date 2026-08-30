//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "island" as Island
import "keybindings" as Keybindings
import "wallpicker" as WallPicker

ShellRoot {
    id: root

    Island.Island {
        id: island
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
        onPressed: island.shown = !island.shown
    }

    // Super+N — open / close the island's control centre (replaces the old hub)
    GlobalShortcut {
        name: "hubToggle"
        description: "Toggle island hub"
        onPressed: island.hubOpen = !island.hubOpen
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
