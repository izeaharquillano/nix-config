# Config

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile` store copies. These are **not** Nix modules — for Nix-native configuration, use `programs.<name>` in Home Manager modules instead.

## How Dotfiles Are Consumed

In `modules/home/base/core/*.nix` and `modules/home/linux/gui/*.nix`, config files are referenced via `xdg.configFile` through the `flakeRoot` specialArg (so moves never break the paths):

```nix
# Single file
xdg.configFile."kitty/kitty.conf".source = flakeRoot + /config/kitty/kitty.conf;

# Directory (hypr/, nvim/)
xdg.configFile."hypr" = {
  source = flakeRoot + /config/hypr;
  recursive = true;
};
```

## Host-Specific Configs

Host-specific settings live in `modules/hosts/<name>/config/` and are store-copied by the host's HM file:

- **Niri**: `niri-host-settings.kdl` — included by `config.kdl` via `include "./niri-host-settings.kdl"`
- **Hyprland**: `hypr-host-settings.lua` — loaded via `require("hypr-host-settings")`
- **Noctalia**: `noctalia-host-settings.toml` — written to `host-settings.toml` by `modules/home/linux/gui/noctalia.nix`

## Adding a New Dotfile

1. Place config file(s) in `config/<app>/`
2. Create a dendritic piece in `modules/home/base/core/<app>.nix` or `modules/home/linux/gui/<app>.nix` with the appropriate `xdg.configFile` reference (via `flakeRoot`)
3. It is picked up by `import-tree` automatically; add it to the `home-linux-core`/`home-linux-gui` collector so hosts compose it
