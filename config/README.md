# Config

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile`.

## Contents

```
config/
├── ghostty/config       # Ghostty terminal config
├── hypr/                # Hyprland Lua config (keybinds, monitors, rules, plugins)
├── niri/config.kdl      # Niri column-based tiling WM config
├── noctalia/config.toml # Noctalia Wayland bar/shell
├── nvim/                # Neovim LazyVim config (Lua)
└── tmux/tmux.conf       # Tmux config
```

## How Dotfiles Are Consumed

In `home/desktop/*.nix`, each module links its config into `~/.config/`:

```nix
# Example from home/desktop/ghostty.nix
xdg.configFile."ghostty/config".source = ../../config/ghostty/config;
```

This creates a symlink at `~/.config/ghostty/config` pointing to this file.

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
