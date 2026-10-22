-- #############
-- ### INPUT ###
-- #############

-- # https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
    input = {
        kb_layout = "us, it",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = 0, -- # -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = false
        }
    }
})

hl.device({
  name      = "wch.cn Epomaker TH65 Keyboard",  -- match hyprctl output exactly
  enabled   = true,      -- make sure Hyprland attaches the device
  keybinds  = true,      -- allow this keyboard to trigger Hyprland keybinds
  kb_layout = "us,it",   -- your layouts
  kb_options = "grp:alt_shift_toggle", -- example: Alt+Shift to toggle layout
})
