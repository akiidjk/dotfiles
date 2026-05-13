local inFocusOpacity = "0.95"
local notInFocusOpacity = "0.8"



hl.window_rule({
    suppress_event = "maximize",
    match = {
        class = ".*"
    }
})

hl.window_rule({
    no_initial_focus = true,
    match = {
        class = "^$",
        title = "^$",
        xwayland = 1,
        float = 1,
        fullscreen = 0,
        pin = 0
    }
})


hl.window_rule({
    opacity = inFocusOpacity .. " " .. notInFocusOpacity,
    match = { title = "^.*().*$" }
})

hl.window_rule({
    opacity = "1.0",
    match = { class = ".*(kitty).*$" }
})

hl.window_rule({
    opacity = inFocusOpacity .. " " .. notInFocusOpacity,
    match = { class = "^(firefox|brave|chromium|librewolf|qutebrowser|zen-browser)$" }
})

hl.window_rule({
    opacity = inFocusOpacity .. " " .. notInFocusOpacity,
    match = { title = "^.*(Spotify).*$" }
})

hl.window_rule({
    opacity = inFocusOpacity .. " " .. notInFocusOpacity,
    match = { title = "^.*(Discord).*$" }
})

hl.window_rule({
    opacity = inFocusOpacity .. " " .. notInFocusOpacity,
    match = { title = "^.*(Thunar|nemo).*$" }
})

hl.window_rule({
    opacity = "0.80",
    float = true,
    size = { 600, 400 },
    match = { class = "^(nwg-displays)$" }
})

hl.window_rule({
    opacity = 0.80,
    float = true,
    size = { 600, 400 },
    match = { class = "^(blueman-manager)$" }
})

hl.window_rule({
    opacity = 0.80,
    float = true,
    size = { 600, 400 },
    match = { class = "^(org.pulseaudio.pavucontrol)$" }
})

hl.window_rule({
    opacity = "0.0 override",
    no_anim = 1,
    no_initial_focus = 1,
    max_size = { 1, 1 },
    no_blur = 1,
    match = { class = "^(xwaylandvideobridge)$" }
})

hl.window_rule({
    fullscreen = true,
    tile = true,
    match = {
        class = "dev.zed.Zed",
    }
})

hl.window_rule({
    float = true,
    opacity = "1.0",
    match = {
        title = "^(Picture-in-Picture|Firefox|Zen)$"
    }
})
