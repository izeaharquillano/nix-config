# Config

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile` store copies. These are **not** Nix modules — for Nix-native configuration, use `programs.<name>` in Home Manager modules instead.

## How Dotfiles Are Consumed

In `modules/programs/shell/*.nix` and `modules/programs/desktop/*.nix`, config files are referenced via `xdg.configFile` through the `flakeRoot` specialArg (so moves never break the paths):

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
- **Noctalia**: `noctalia-host-settings.toml` — wired to `host-settings.toml` by the host's `home.nix`

## Adding a New Dotfile

1. Place config file(s) in `config/<app>/`
2. Create a dendritic piece in `modules/programs/<group>/<app>.nix` (or extend the feature closure in `modules/services/<feature>/`) with the appropriate `xdg.configFile` reference (via `flakeRoot`)
3. It is picked up by `import-tree` automatically; add it to the `linux-core`/`linux-gui` collector so hosts compose it
