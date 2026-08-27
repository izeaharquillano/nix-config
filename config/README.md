# Config

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile`.

## Contents

```
config/
├── kitty/kitty.conf     # kitty terminal config
├── hypr/                # Hyprland Lua config (keybinds, rules, plugins)
│   ├── hyprland.lua     # Main config (requires hypr-host-settings, animations, etc.)
│   ├── keybindings.lua  # Key bindings
│   ├── windowrules.lua  # Window rules
│   ├── animations.lua   # Animation config
│   └── plugins/         # Hyprland plugins (hyprbars)
├── niri/
│   ├── config.kdl       # Niri config (includes niri-host-settings.kdl)
│   └── config.kdl.old   # Old reference config
├── noctalia/config.toml # Noctalia Wayland bar/shell
├── nvim/                # Neovim LazyVim config (Lua)
├── starship.toml        # Starship prompt config
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

Monitor-specific configs (niri outputs, hyprland monitors) and host-specific noctalia settings live in `home/hosts/<name>/config/` rather than here. They are symlinked by the host-specific HM file (`home/hosts/<name>/default.nix`).

- **Niri**: `home/hosts/<name>/config/niri-host-settings.kdl` is symlinked to `~/.config/niri/niri-host-settings.kdl` and included by `config.kdl` via `include "./niri-host-settings.kdl"`.
- **Hyprland**: `home/hosts/<name>/config/hypr-host-settings.lua` is symlinked to `~/.config/hypr/hypr-host-settings.lua` and loaded via `require("hypr-host-settings")`.
- **Noctalia**: `home/hosts/<name>/config/noctalia-host-settings.toml` (if present) is appended to the generated `settings.toml`.

## Adding a New Dotfile

1. Place your config file(s) in `config/<app>/`
2. Create a module in `home/desktop/<app>.nix`:

```nix
{ ... }:

{
  xdg.configFile."app/config".source = ../../config/app/config;
}
```

3. It will be auto-imported by `scanPaths` in `home/desktop/default.nix`

## Notes

- These are **not** Nix modules -- they are plain config files
- Changes to these files take effect on next home-manager switch
- For Nix-native app configuration, use `programs.<name>` in Home Manager modules instead
