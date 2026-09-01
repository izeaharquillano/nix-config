# Config

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile` store copies. These are **not** Nix modules — for Nix-native configuration, use `programs.<name>` in Home Manager modules instead.

## How Dotfiles Are Consumed

In `home/core/*.nix` and `home/linux/*.nix`, config files are referenced via `xdg.configFile`:

```nix
# Single file
xdg.configFile."kitty/kitty.conf".source = ../../config/kitty/kitty.conf;

# Directory (hypr/, nvim/)
xdg.configFile."hypr" = {
  source = ../../config/hypr;
  recursive = true;
};
```

## Host-Specific Configs

Host-specific settings live in `home/hosts/<name>/config/` and are store-copied by the host's HM file:

- **Niri**: `niri-host-settings.kdl` — included by `config.kdl` via `include "./niri-host-settings.kdl"`
- **Hyprland**: `hypr-host-settings.lua` — loaded via `require("hypr-host-settings")`
- **Noctalia**: `noctalia-host-settings.toml` — written to `host-settings.toml` by `home/linux/noctalia.nix`

## Adding a New Dotfile

1. Place config file(s) in `config/<app>/`
2. Create a module in `home/core/<app>.nix` or `home/linux/<app>.nix` with the appropriate `xdg.configFile` reference
3. It will be auto-imported by `scanPaths` in `default.nix`
