hl.on("config.reloaded", function()
    if hl.plugin.hyprbars ~= nil then
        hl.config({
            plugin = {
                hyprbars = {
                    bar_height = 30,
                    bar_color = "rgb(1a1b26)",
                    bar_blur = true,
                    bar_title_enabled = true,
                    bar_text_size = 12,
                    bar_text_font = "JetBrainsMono Nerd Font",
                    bar_text_align = "center",
                    bar_buttons_alignment = "left",
                    bar_padding = 12,
                    bar_button_padding = 6,
                    ["col.text"] = "rgb(99d1db)",
                    on_double_click = "hyprctl dispatch fullscreen 1",
                },
            },
        })

        hl.plugin.hyprbars.add_button({
            bg_color = "rgb(bf616a)",
            fg_color = "rgb(ffffff)",
            size = 13,
            icon = " ",
            action = "hyprctl dispatch killactive",
        })

        hl.plugin.hyprbars.add_button({
            bg_color = "rgb(ebcb8b)",
            fg_color = "rgb(ffffff)",
            size = 13,
            icon = " ",
            action = "xdg-open ~/.config/hypr/",
        })

        hl.plugin.hyprbars.add_button({
            bg_color = "rgb(a3be8c)",
            fg_color = "rgb(ffffff)",
            size = 13,
            icon = " ",
            action = "hyprctl dispatch fullscreen 1",
        })
    end
end)
