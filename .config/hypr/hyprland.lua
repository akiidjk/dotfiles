--
--                     :::!~!!!!!:.
--                  .xUHWH!! !!?M88WHX:.
--                .X*#M@$!!  !X!M$$$$$$WWx:.
--                :!!!!!!?H! :!$!$$$$$$$$$$8X:
--               !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
--              :!~::!H!<   ~.U$X!?R$$$$$$$$MM!
--              ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
--                !:~~~ .:!M"T#$$$$WX??#MRRMMM!
--                ~?WuxiW*`   `"#$$$$8!!!!??!!!
--              :X- M$$$$       `"T#$T~!8$WUXU~
--             :%`  ~#$$$m:        ~!~ ?$$$$$$
--           :!`.-   ~T$$$$8xx.  .xWW- ~""##*"
-- .....   -~~:<` !    ~?T#$$@@W@*?$$      /`
-- W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :
-- #"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`
-- :::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~
-- .~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `
-- Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!
-- $R@i.~~ !     :   ~$$$$$B$$en:``
-- ?MXT@Wx.~    :     ~"##*$$$$M~
-- Config by @akiidjk

-- Setup gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Some config
hl.config({
    dwindle = {
        -- force_split    = 0,
        preserve_split = true,
        -- smart_split                  = false,
        -- smart_resizing               = true,
        -- permanent_direction_override = false,
        -- special_scale_factor         = 1,
        -- split_width_multiplier       = 1.0,
        -- use_active_for_splits        = true,
        -- default_split_ratio          = 1.0,
        -- split_bias                   = 0,
        -- precise_mouse_move           = false,
    },
})

-- Load monitors config
require("monitors")

-- Nvidia settings
hl.env("LIBVA_DRIVER_NAME.nvidia", "true")
hl.env("__GLX_VENDOR_LIBRARY_NAME.nvidia", "true")

require("autostart")


-- #############################
-- ### ENVIRONMENT VARIABLES ###
-- #############################

--    # See https://wiki.hyprland.org/Configuring/Environment-variables/
hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_SIZE", 24)


-- #####################
-- ### LOOK AND FEEL ###
-- #####################
require("hyprcolors")
require("animation")

hl.config({
    misc = {
        force_default_wallpaper = -1, --  # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true  --  # If true disables the random hyprland logo / anime girl background. :(
    }
})


-- #############
-- ### INPUT ###
-- #############
require("input")
require("keybinds")

-- ##############################
-- ### WINDOWS AND WORKSPACES ###
-- ##############################
-- # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules
require("windowrule")


-- ##################
-- ### EXTENSIONS ###
-- ##################
require("vicinae")
