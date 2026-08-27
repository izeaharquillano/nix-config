# Home Manager Modules

User-level configuration managed by Home Manager.

## Structure

```
home/
├── core/                    # Shared across all hosts
│   ├── default.nix          # Aggregator + stateVersion, username
│   ├── shell.nix            # Bash, zoxide, aliases
│   ├── git.nix              # Git user name/email
│   ├── packages.nix         # CLI tools (fd, fzf, btop-cuda, ripgrep, opencode, etc.)
│   └── xdg.nix              # XDG user directories + portal config
├── desktop/                 # Desktop/GUI app configs
│   ├── default.nix          # Aggregator
│   ├── gtk.nix              # GTK theme, cursor
│   ├── kitty.nix            # Kitty terminal
│   ├── hyprland.nix         # Hyprland config (symlinks config/hypr/)
│   ├── niri.nix             # Niri config (symlinks config/niri/)
│   ├── noctalia.nix         # Noctalia lockscreen/bar (merges host settings into settings.toml)
│   ├── nvim.nix             # Neovim LazyVim config (xdg.configFile)
│   ├── obsidian.nix         # Obsidian
│   ├── starship.nix         # Starship prompt
│   ├── yazi.nix             # Yazi file manager + gruvbox theme
│   ├── tmux.nix             # Tmux config
│   ├── packages.nix         # Desktop packages (ncdu, waybar, mpv, discord-ptb, etc.)
│   ├── zen-browser.nix      # Zen Browser
│   └── terminal.nix         # Terminal packages (kitty)
└── hosts/
    ├── padrick/
    │   ├── default.nix      # Host-specific HM: imports core + desktop, symlinks hardware configs
    │   ├── packages.nix     # Host-specific user packages
    │   └── config/          # Host-specific dotfiles (niri, hyprland, noctalia)
    │       ├── niri-host-settings.kdl
    │       ├── hypr-host-settings.lua
    │       └── noctalia-host-settings.toml
    └── jobert/
        ├── default.nix
        ├── packages.nix
        └── config/
            ├── niri-host-settings.kdl
            └── hypr-host-settings.lua
```

## Module Types

- **`core/`** - Essential user config (shell, git, packages). Always imported.
- **`desktop/`** - GUI applications and dotfiles. Only for desktop hosts.
- **`hosts/<name>/`** - Host-specific overrides, flake input imports, and hardware config symlinks.

## How It Works

The host's HM entry point (`home/hosts/<name>/default.nix`) imports `core/` and `desktop/`, plus any flake module inputs (niri, noctalia, zen-browser).

Raw dotfiles in `config/` are symlinked into `~/.config/` via `xdg.configFile`. Monitor/window-manager hardware configs and host-specific settings live in `home/hosts/<name>/config/` and are symlinked using relative paths. The `hostname` is passed via `extraSpecialArgs` in `flake.nix`, allowing shared modules like `noctalia.nix` to read host-specific settings.

For niri, the main `config.kdl` uses `include "./niri-host-settings.kdl"` to pull in the host-specific hardware file. For hyprland, `require("hypr-host-settings")` loads the host-specific `hypr-host-settings.lua`. For noctalia, `noctalia-host-settings.toml` (if present) is appended to the generated `settings.toml`.

## Adding a Module

1. Create a `.nix` file in `home/core/` or `home/desktop/`
2. It will be auto-imported by `scanPaths` in `default.nix`
3. Follow the Home Manager module pattern:

```nix
{ pkgs, ... }:

{
  programs.<name> = {
    enable = true;
    # options...
  };
}
```

## Adding a Dotfile

1. Place the config file in `config/<app>/`
2. Create or update a module in `home/desktop/`:

```nix
{ ... }:

{
  xdg.configFile."app/config".source = ../../config/app/config;
}
```

For directories, use `recursive = true`:

```nix
xdg.configFile."app" = {
  source = ../../config/app;
  recursive = true;
};
```

## Host-Specific Overrides

In `home/hosts/<name>/default.nix`, add host-specific settings after the imports. Hardware config files in `home/hosts/<name>/config/` are symlinked using relative paths:

```nix
{ config, inputs, ... }:

{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;

  xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
}
```

Noctalia lockscreen widget settings can be placed in `home/hosts/<name>/config/noctalia-host-settings.toml`. If present, they are automatically appended to the generated `settings.toml` by `home/desktop/noctalia.nix` (which uses the `hostname` arg passed from `flake.nix`).

Add host-specific user packages in `home/hosts/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # user packages only needed on this host
  ];
}
```
