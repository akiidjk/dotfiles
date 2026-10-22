-- #################
-- ### AUTOSTART ###
-- #################

hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")

    -- Notifications are served by MacShell (see macshell.lua)
    hl.exec_cmd("~/.config/hypr/scripts/spotify-notify.sh")

    -- For screen sharing
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment")
    hl.exec_cmd("~/.config/hypr/scripts/screensharing.sh")

    -- Wi-Fi / Bluetooth live in the MacShell Control Center (no nm-applet / blueman-applet)

    -- set up the wallpaper
    hl.exec_cmd("awww-daemon & sleep 1 && ~/.config/hypr/scripts/init_wallpapers.sh")

    -- Start plugins
    hl.exec_cmd("hyprpm reload")
end)
