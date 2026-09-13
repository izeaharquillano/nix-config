hl.config({
    input = {
        sensitivity = 0.0,
    },
})

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.20",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start mic-mute-led-sync")
end)
