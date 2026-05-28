local terminal = "kitty"
local fileManager = "nautilus"
local browser = "zen-browser"
local editor = "zed"

mainMod = "SUPER"

-- Exec
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), { description = "Open terminal" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "Open file manager" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser), { description = "Open browser" })
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(editor), { description = "Open editor" })
hl.bind("ALT + L", hl.dsp.exec_cmd("hyprlock --grace 5"), { description = "Lock screen" })

hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/hyprPicker.sh"),
    { description = "Color picker" })

hl.bind("CTRL + SHIFT + A", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play/pause media" })
hl.bind("CTRL + SHIFT + D", hl.dsp.exec_cmd("playerctl next"), { description = "Next media" })
hl.bind("CTRL + SHIFT + S", hl.dsp.exec_cmd("playerctl previous"), { description = "Previous media" })

-- WM Control binds
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit(), { description = "Exit WM" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 1, internal = 0, client = 2 }),
    { description = "Maximize window" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = 0, internal = 0, client = 2 }),
    { description = "Fullscreen window" })
hl.bind(mainMod .. " + T", hl.dsp.window.float(), { description = "Toggle floating" })
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
hl.bind(mainMod .. " + G", hl.dsp.layout("swapsplit"), { description = "Swap split" })

-- Window Switch
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

-- Quickshell shortcut
hl.bind(mainMod .. " + H", hl.dsp.global("quickshell:barToggle"), { description = "Toggle quickshell bar" })
hl.bind(mainMod .. " + N", hl.dsp.global("quickshell:hubToggle"), { description = "Toggle quickshell hub" })
hl.bind(mainMod .. " + W", hl.dsp.global("quickshell:wallPickerToggle"), { description = "Toggle wall picker" })
hl.bind(mainMod .. " + K", hl.dsp.global("quickshell:keybindingsToggle"), { description = "Toggle keybindings" })
hl.bind(mainMod .. " + L", hl.dsp.global("quickshell:changeBarLayout"), { description = "Change bar layout" })

-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = key }), { description = "Focus workspace " .. key })
    hl.bind(mainMod .. " + SHIFT +" .. key, hl.dsp.window.move({ workspace = key }),
        { description = "Move to workspace " .. key })
end
-- hl.bind(mainMod .. " + 0", hl.dsp.workspace(10))
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }), { description = "Focus previous workspace" })
hl.bind(mainMod .. " + left", hl.dsp.focus({ workspace = "-1" }), { description = "Focus left workspace" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "+1" }), { description = "Focus right workspace" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }),
    { description = "Resize window left" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }),
    { description = "Resize window right" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }),
    { description = "Resize window up" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }),
    { description = "Resize window down" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    { repeating = true, description = "Raise volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { repeating = true, description = "Lower volume" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { repeating = true, description = "Toggle mute" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { repeating = true, description = "Toggle mic mute" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 30%+"),
    { repeating = true, description = "Raise brightness" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 30%-"),
    { repeating = true, description = "Lower brightness" })

-- Screenshot a window
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'), { description = "Screenshot region" })

-- Night mode and ToggleMirror scripts
hl.bind("SUPER + M", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/toggleMirror.sh"), { description = "Toggle mirror" })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/nightmode.sh"),
    { description = "Toggle night mode" })
