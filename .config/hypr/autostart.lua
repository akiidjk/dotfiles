-- #################
-- ### AUTOSTART ###
-- #################

hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")

    -- Notification
    hl.exec_cmd("mako")
    hl.exec_cmd("~/.config/mako/scripts/spotify-notify.sh")

    -- For screen sharing
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment")
    hl.exec_cmd("~/.config/hypr/scripts/screensharing.sh")
    hl.exec_cmd("xwaylandvideobridge")

    -- Bluetooth
    hl.exec_cmd("blueman-applet") -- Make sure you have installed blueman
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-tray")

    -- For keyboard
    hl.exec_cmd("fcitx5 -D")

    -- set up the wallpaper
    hl.exec_cmd("awww-daemon & sleep 1 && ~/.config/hypr/scripts/init_wallpapers.sh")

    hl.exec_cmd("quickshell")

    -- Start plugins
    hl.exec_cmd("hyprpm reload")
end)
