local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "noctalia msg panel-toggle launcher"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("zen-beta"))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F",  hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + H",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J",  hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + H",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J",  hl.dsp.window.move({ direction = "d" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl --class=backlight set +5%"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl --class=backlight set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("Print",                  hl.dsp.exec_cmd("hyprshot -m region --output-folder ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + Print",    hl.dsp.exec_cmd("hyprshot -m window --output-folder ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output --output-folder ~/Pictures/Screenshots"))

hl.bind(mainMod .. " + Y",         hl.dsp.exec_cmd("hyprctl plugin load /var/cache/hyprpm/izeah/hyprland-plugins/hyprbars.so"))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("hyprctl plugin unload /var/cache/hyprpm/izeah/hyprland-plugins/hyprbars.so"))

hl.bind(mainMod .. " + backspace", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center calendar"))
hl.bind(mainMod .. " + CTRL + E", hl.dsp.exec_cmd("kitty yazi"))

hl.bind(mainMod .. " + CTRL + EQUAL",    hl.dsp.exec_cmd("output-scale +"))
hl.bind(mainMod .. " + CTRL + MINUS",    hl.dsp.exec_cmd("output-scale -"))
hl.bind(mainMod .. " + CTRL + 1",        hl.dsp.exec_cmd("output-scale 1"))
hl.bind(mainMod .. " + CTRL + 2",        hl.dsp.exec_cmd("output-scale 1.25"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("noctalia msg bar-toggle"))
