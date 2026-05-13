require("colors")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        -- # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        col = {
            active_border = primary,
            inactive_border = on_primary
        },

        -- # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        --   -- # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle"
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,

        -- # Change transparency of focused and unfocused windows
        active_opacity = 1,
        inactive_opacity = 1,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = background,
        },

        -- # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696
        }

    }
})
