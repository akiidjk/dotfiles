-- MacShell (fork in ~/.config/quickshell/MacShell) + MacLock.
-- awww-daemon, hypridle and the clipboard watchers are started in autostart.lua; nothing here starts them twice.
-- ponytail: plain `qs -c MacShell`, no macshell-start supervisor; add it back if the shell ever needs crash-restart.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c MacShell")
end)

-- A crashed MacLock can be relaunched instead of leaving the red "lock died" screen.
hl.config({ misc = { allow_session_lock_restore = true } })

local qs = "qs -c MacShell ipc call "
local lock = "sh ~/.config/quickshell/MacLock/lock-via-ipc.sh"

hl.bind("SUPER + comma",  hl.dsp.exec_cmd(qs .. "settings toggle"),    { description = "MacShell Settings" })
hl.bind("ALT + TAB",      hl.dsp.exec_cmd(qs .. "switcher next"),      { description = "Window switcher" })
hl.bind("PRINT",          hl.dsp.exec_cmd(qs .. "screenshot region"),  { description = "Screenshot (MacShell)" })
hl.bind("SUPER + H",      hl.dsp.exec_cmd(qs .. "island toggle"),      { description = "Show / hide the top bar" })
hl.bind("SUPER + N",      hl.dsp.exec_cmd(qs .. "island hub"),         { description = "Island hub / Control Center" })
hl.bind("SUPER + W",      hl.dsp.exec_cmd(qs .. "wallpicker toggle"),  { description = "Wallpaper picker" })
hl.bind("SUPER + K",      hl.dsp.exec_cmd(qs .. "keybinds toggle"),    { description = "Keybindings" })
hl.bind("SUPER + L",      hl.dsp.exec_cmd(lock),                       { description = "Lock screen" })
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(lock), { locked = true })

-- Hardware keys: MacShell handles them and shows its OSD; wpctl / brightnessctl / playerctl when the shell is down.
local function hw(action, fallback)
    return "sh -c '" .. qs .. "hardware " .. action .. " >/dev/null 2>&1 || " .. fallback .. "'"
end
local hwkeys = {
    { "XF86AudioRaiseVolume",  hw("volumeUp",       "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),   true  },
    { "XF86AudioLowerVolume",  hw("volumeDown",     "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        true  },
    { "XF86AudioMute",         hw("mute",           "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       false },
    { "XF86AudioMicMute",      hw("micMute",        "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     false },
    { "XF86MonBrightnessUp",   hw("brightnessUp",   "brightnessctl -q set 5%+"),                         true  },
    { "XF86MonBrightnessDown", hw("brightnessDown", "brightnessctl -q -n1 set 5%-"),                     true  },
    { "XF86KbdBrightnessUp",   "brightnessctl -q -d '*kbd_backlight*' set 10%+",                         true  },
    { "XF86KbdBrightnessDown", "brightnessctl -q -d '*kbd_backlight*' set 10%-",                         true  },
    { "XF86AudioPlay",         "playerctl play-pause",                                                   false },
    { "XF86AudioPause",        "playerctl pause",                                                        false },
    { "XF86AudioNext",         "playerctl next",                                                         false },
    { "XF86AudioPrev",         "playerctl previous",                                                     false },
}
for _, k in ipairs(hwkeys) do
    hl.bind(k[1], hl.dsp.exec_cmd(k[2]), { locked = true, repeating = k[3] })
end

-- Liquid Glass: blur behind the shell surfaces. Every mac* layer animates itself, so the global
-- layers popin from animation.lua is switched off for them.
hl.layer_rule({ name = "mac-noanim", match = { namespace = "^mac" }, no_anim = true })
hl.layer_rule({ name = "macdock",    match = { namespace = "^macdock$" },   blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "macbarbg",   match = { namespace = "^macbarbg$" },  blur = true, ignore_alpha = 0.05 })
hl.layer_rule({ name = "macisland",  match = { namespace = "^macisland$" }, blur = true, ignore_alpha = 0.05 })

-- MacShell's own windows draw their own edge
hl.window_rule({
    name = "macshell-settings",
    match = { title = "^macshell Settings$" },
    opacity = "0.82 0.85 1",
    border_size = 0,
    rounding = 12,
})
hl.window_rule({
    name = "macshell-about",
    match = { title = "^About This Linux$" },
    opacity = "0.82 0.85 1",
    border_size = 0,
    rounding = 18,
})
