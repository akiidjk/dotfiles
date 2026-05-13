--################
--### MONITORS ###
--################

-- hl.monitor({
--     output = "eDP-1",
--     mode = "1920x1080@60",
--     position = "0x0",
--     scale = "1"
-- })

-- hl.monitor({
--     output = "HDMI-A-1",
--     mode = "1920x1080@60",
--     position = "0x1280",
--     scale = "1",
--     mirror = "eDP-1"
-- })


hl.monitor({
    output = "DP-3",
    mode = "1920x1080@60",
    position = "0x450",
    scale = "1"
})

hl.monitor({
    output = "DP-2",
    mode = "1920x1080@144",
    position = "1920x380",
    scale = "1",
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60",
    position = "3840x0",
    scale = "1",
    transform = true
})
