# Config

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile`.

## Contents

```
config/
├── kitty/kitty.conf     # Kitty terminal config
├── hypr/                # Hyprland Lua config (keybinds, rules, plugins)
│   ├── hyprland.lua     # Main config (requires hypr-host-settings, animations, etc.)
│   ├── keybindings.lua  # Key bindings
│   ├── windowrules.lua  # Window rules
│   ├── animations.lua   # Animation config
│   └── plugins/         # Hyprland plugins (hyprbars)
├── niri/
│   └── config.kdl       # Niri config (includes niri-host-settings.kdl)
├── noctalia/config.toml # Noctalia Wayland bar/shell (symlinked, wallpaper in wallpaper.toml)
├── nvim/                # Neovim LazyVim config (Lua)
├── starship.toml        # Starship prompt config
└── tmux/tmux.conf       # Tmux config
```

## How Dotfiles Are Consumed

In `home/desktop/*.nix`, individual config files are live-symlinked into `~/.config/` via `config.lib.file.mkOutOfStoreSymlink`:

```nix
# Example from home/desktop/terminal.nix
{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/kitty/kitty.conf";
}
```

This creates a symlink at `~/.config/kitty/kitty.conf` pointing to this file. Edits take effect immediately without a rebuild.

Directories with multiple files (like `hypr/` and `nvim/`) use store copies with `recursive = true` instead, because `mkOutOfStoreSymlink` on a directory conflicts with Home Manager's file management when other modules also create files inside that directory.

## Host-Specific Configs

Host-specific settings (niri, hyprland, noctalia) live in `home/hosts/<name>/config/` rather than here. They are store-copied by the host-specific HM file (`home/hosts/<name>/default.nix`).

- **Niri**: `home/hosts/<name>/config/niri-host-settings.kdl` is symlinked to `~/.config/niri/niri-host-settings.kdl` and included by `config.kdl` via `include "./niri-host-settings.kdl"`.
- **Hyprland**: `home/hosts/<name>/config/hypr-host-settings.lua` is symlinked to `~/.config/hypr/hypr-host-settings.lua` and loaded via `require("hypr-host-settings")`.
- **Noctalia**: `home/hosts/<name>/config/noctalia-host-settings.toml` (if present) is written to `host-settings.toml` in `~/.config/noctalia/` by `home/desktop/noctalia.nix`. Wallpaper settings are in a separate Nix-generated `wallpaper.toml`.

## Adding a New Dotfile

1. Place your config file(s) in `config/<app>/`
2. Create a module in `home/desktop/<app>.nix`:

For a single file (live symlink):

```nix
{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."app/config".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/app/config";
}
```

For a directory (store copy, requires rebuild):

```nix
{ ... }:

{
  xdg.configFile."app" = {
    source = ../../config/app;
    recursive = true;
  };
}
```

3. It will be auto-imported by `scanPaths` in `home/desktop/default.nix`

## Notes

- These are **not** Nix modules -- they are plain config files
- Individual files: edits take effect **immediately** (no rebuild needed) via live symlinks
- Directories: changes require a rebuild (store copies)
- For Nix-native app configuration, use `programs.<name>` in Home Manager modules instead
