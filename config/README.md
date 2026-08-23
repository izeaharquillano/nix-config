# Config

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile`.

## Contents

```
config/
├── kitty/kitty.conf     # kitty terminal config
├── hypr/                # Hyprland Lua config (keybinds, rules, plugins)
│   ├── hyprland.lua     # Main config (requires monitors, animations, etc.)
│   ├── keybindings.lua  # Key bindings
│   ├── windowrules.lua  # Window rules
│   ├── animations.lua   # Animation config
│   └── plugins/         # Hyprland plugins (hyprbars)
├── niri/
│   ├── config.kdl       # Niri config (includes niri-hardware.kdl)
│   └── config.kdl.old   # Old reference config
├── noctalia/config.toml # Noctalia Wayland bar/shell
├── nvim/                # Neovim LazyVim config (Lua)
└── tmux/tmux.conf       # Tmux config
```

## How Dotfiles Are Consumed

In `home/desktop/*.nix`, each module symlinks its config into `~/.config/`:

```nix
# Example from home/desktop/kitty.nix
xdg.configFile."kitty/kitty.conf".source = ../../config/kitty/kitty.conf;
```

This creates a symlink at `~/.config/kitty/kitty.conf` pointing to this file.

## Monitor Configs

Monitor-specific configs (niri outputs, hyprland monitors) live in `hosts/<name>/` rather than here. They are symlinked by the host-specific HM file (`home/hosts/<name>.nix`).

- **Niri**: `hosts/<name>/niri-hardware.kdl` is symlinked to `~/.config/niri/niri-hardware.kdl` and included by `config.kdl` via `include "./niri-hardware.kdl"`.
- **Hyprland**: `hosts/<name>/monitors.lua` is symlinked to `~/.config/hypr/monitors.lua` and loaded via `require("monitors")`.

## Adding a New Dotfile

1. Place your config file(s) in `config/<app>/`
2. Create a module in `home/desktop/<app>.nix`:

```nix
{ ... }:

{
  xdg.configFile."app/config".source = ../../config/app/config;
}
```

3. Import the module in `home/desktop/default.nix`

## Notes

- These are **not** Nix modules -- they are plain config files
- Changes to these files take effect on next home-manager switch
- For Nix-native app configuration, use `programs.<name>` in Home Manager modules instead
