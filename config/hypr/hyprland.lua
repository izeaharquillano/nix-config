local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = os.getenv("HOME") .. "/.config/rofi/scripts/launcher_t1"

hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 6,
        border_size = 2,
        col = {
            active_border   = "rgba(458588ff)",
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = -0.5,
        touchpad = {
            natural_scroll = true,
        },
    },
  cursor = {
    no_hardware_cursors = 0,
  },
})

hl.env("GDK_SCALE", "1")

hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
    hl.exec_cmd("netbird-ui")
end)

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- hl.device({
--     name        = "epic-mouse-v1",
--     sensitivity = -0.5,
-- })

require("hypr-host-settings")
require("animations")
require("keybindings")
require("windowrules")
require("plugins.hyprbars")
