local terminal = "kitty"
local fileManager = "nautilus"
local browser = "zen-browser"
local editor = "zed"

mainMod = "SUPER"

-- Exec
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(editor))
hl.bind("ALT + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/hyprPicker.sh"))

hl.bind("CTRL + SHIFT + A", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("CTRL + SHIFT + D", hl.dsp.exec_cmd("playerctl next"))
hl.bind("CTRL + SHIFT + S", hl.dsp.exec_cmd("playerctl previous"))

-- WM Control binds
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(1))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen(2))
hl.bind(mainMod .. " + T", hl.dsp.window.float())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + G", hl.dsp.layout("swapsplit"))

-- Window Switch
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Quickshell shortcut
hl.bind(mainMod .. " + H", hl.dsp.global("quickshell:barToggle"))
hl.bind(mainMod .. " + N", hl.dsp.global("quickshell:hubToggle"))
hl.bind(mainMod .. " + W", hl.dsp.global("quickshell:wallPickerToggle"))
hl.bind(mainMod .. " + K", hl.dsp.global("quickshell:keybindingsToggle"))
hl.bind(mainMod .. " + L", hl.dsp.global("quickshell:changeBarLayout"))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = key }))
    hl.bind(mainMod .. " + SHIFT +" .. key, hl.dsp.window.move({ workspace = key }))
end
-- hl.bind(mainMod .. " + 0", hl.dsp.workspace(10))
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -40, y = 0 }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 40, y = 0 }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -40 }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 40 }))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 30%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 30%-"), { repeating = true })

-- Screenshot a window
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

-- Night mode and ToggleMirror scripts
hl.bind("SUPER + M", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/toggleMirror.sh"))
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/nightmode.sh"))
