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
hl.bind("ALT + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock screen" })

hl.bind(
    "SUPER + SHIFT + C",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/hyprPicker.sh"),
    { description = "Color picker" }
)

hl.bind("CTRL + SHIFT + A", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play/pause media" })
hl.bind("CTRL + SHIFT + D", hl.dsp.exec_cmd("playerctl next"), { description = "Next media" })
hl.bind("CTRL + SHIFT + S", hl.dsp.exec_cmd("playerctl previous"), { description = "Previous media" })

-- WM Control binds
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit(), { description = "Exit WM" })
hl.bind(
    mainMod .. " + ALT + F",
    hl.dsp.window.fullscreen({ mode = 1, internal = 0, client = 2 }),
    { description = "Maximize window" }
)
hl.bind(
    mainMod .. " + SHIFT + F",
    hl.dsp.window.fullscreen({ mode = 0, internal = 0, client = 2 }),
    { description = "Fullscreen window" }
)
hl.bind(
    mainMod .. " + F",
    hl.dsp.layout("fit active"),
    { description = "Make fit the window to all cols" }
)
hl.bind(mainMod .. " + T", hl.dsp.window.float(), { description = "Toggle floating" })
hl.bind(mainMod .. " + J", hl.dsp.layout("swapcol r"), { description = "Swap right the col" })
hl.bind(mainMod .. " + G", hl.dsp.layout("swapcol l"), { description = "Swap left the col" })

-- Window Switch
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

-- MacShell shortcuts (bar / island / pickers / lock) live in macshell.lua

-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = key }), { description = "Focus workspace " .. key })
    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = key }),
        { description = "Move to workspace " .. key }
    )
end
-- hl.bind(mainMod .. " + 0", hl.dsp.workspace(10))
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }), { description = "Focus previous workspace" })
-- hl.bind(mainMod .. " + left", hl.dsp.focus({ workspace = "-1" }), { description = "Focus left workspace" })
-- hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "+1" }), { description = "Focus right workspace" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

hl.bind(
    "SUPER + SHIFT + left",
    hl.dsp.window.resize({ x = -40, y = 0, relative = true }),
    { description = "Resize window left" }
)
hl.bind(
    "SUPER + SHIFT + right",
    hl.dsp.window.resize({ x = 40, y = 0, relative = true }),
    { description = "Resize window right" }
)
hl.bind(
    "SUPER + SHIFT + up",
    hl.dsp.window.resize({ x = 0, y = -40, relative = true }),
    { description = "Resize window up" }
)
hl.bind(
    "SUPER + SHIFT + down",
    hl.dsp.window.resize({ x = 0, y = 40, relative = true }),
    { description = "Resize window down" }
)

-- Volume / brightness / media keys: MacShell hardware IPC (OSD), see macshell.lua

-- Screenshot a window
hl.bind(
    "SUPER + SHIFT + S",
    hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'),
    { description = "Screenshot region" }
)
hl.bind(
    "SUPER + SHIFT + M",
    hl.dsp.exec_cmd("qs -c MacShell ipc call hardware micMute"),
    { description = "Mute / unmute the microphone" }
)
hl.bind(
    "SUPER + SHIFT + N",
    hl.dsp.exec_cmd("qs -c MacShell ipc call scratchpad toggle"),
    { description = "Scratchpad" }
)
hl.bind(
    "SUPER + SHIFT + T",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/screen-text.sh"),
    { description = "Copy text / QR code from screen" }
)

-- ToggleMirror script (Night Shift lives in the MacShell Control Center)
hl.bind("SUPER + M", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/toggleMirror.sh"), { description = "Toggle mirror" })
