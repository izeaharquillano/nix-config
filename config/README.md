# config/ Dotfiles

Raw application configuration files (dotfiles) consumed by Home Manager via `xdg.configFile` store copies. These are **not** Nix modules — for Nix-native configuration, use `programs.<name>` in Home Manager modules instead.

| Path | Consumed by |
|---|---|
| `kitty/kitty.conf` | `programs/shell/terminal.nix` (hm.terminal) |
| `hypr/` (lua) | `programs/desktop/hyprland/` (hm.hyprland, recursive) |
| `niri/config.kdl` | `programs/desktop/niri/` (hm.niri) |
| `noctalia/config.toml` | `programs/desktop/noctalia.nix` (hm.noctalia; wallpapers from `_img/wallpapers`) |
| `nvim/` | `programs/dev/nvim.nix` (hm.nvim, recursive) |
| `starship.toml` | `programs/shell/shell.nix` (hm.shell) |
| `tmux/tmux.conf`, `vscode/` | Referenced by their respective HM modules (see programs/) |

## How Dotfiles Are Consumed

In the Home Manager modules under `modules/programs/*/*.nix` (shell/terminal.nix, shell/shell.nix, desktop/hyprland/, desktop/niri/, dev/nvim.nix), config files are referenced through `xdg.configFile` using the `flakeRoot` specialArg — so moving this directory never breaks the paths:

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

Host-specific settings live in `modules/hosts/<name>/config/` and are store-copied by the host's HM file through the shared `mkHostConfigFiles ./config` helper. Missing files are skipped, so a host with only one compositor doesn't need all three stubs:

- **Niri**: `niri-host-settings.kdl` — included by `config.kdl` via `include "./niri-host-settings.kdl"`
- **Hyprland**: `hypr-host-settings.lua` — loaded via `require("hypr-host-settings")`
- **Noctalia**: `noctalia-host-settings.toml` — wired to `noctalia/host-settings.toml` by the host's `home.nix`

## Adding a New Dotfile

1. Place config file(s) in `config/<app>/`
2. Create a dendritic piece in `modules/programs/<group>/<app>.nix` (or extend the feature closure in `modules/services/<feature>/`) with the appropriate `xdg.configFile` reference (via `flakeRoot`)
3. It is picked up by import-tree automatically. If it belongs in the base system, add it to the linux-core/linux-gui collector; if it is an optional feature (e.g. vscode, recording, p2p), hosts import it directly in `home.nix` instead.
