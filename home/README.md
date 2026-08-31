# Home Manager Modules

User-level configuration managed by Home Manager, organized by platform.

## Structure

```
home/
├── core/                        # Cross-platform (works on Linux + macOS)
│   ├── default.nix              # Aggregator + stateVersion, username, platform-aware homeDirectory
│   ├── shell.nix                # Bash, zsh, git, starship, zoxide, aliases
│   ├── git.nix                  # Git configuration
│   ├── packages.nix             # CLI tools (fd, fzf, ripgrep, opencode, etc.)
│   ├── xdg.nix                  # XDG user directories
│   ├── terminal.nix             # Kitty terminal
│   ├── nvim.nix                 # Neovim LazyVim config (store copy, recursive)
│   ├── starship.nix             # Starship prompt
│   ├── yazi.nix                 # Yazi file manager + gruvbox theme
│   ├── tmux.nix                 # Tmux config
│   └── obsidian.nix             # Obsidian
├── linux/                       # Linux-only home modules
│   ├── default.nix              # Aggregator
│   ├── gtk.nix                  # GTK theme, cursor
│   ├── hyprland.nix             # Hyprland config (store copy, recursive)
│   ├── niri.nix                 # Niri config
│   ├── noctalia.nix             # Noctalia lockscreen/bar (config.toml + wallpaper.toml + host-settings.toml)
│   ├── mimeapps.nix             # Nemo desktop entry + MIME associations
│   ├── shell.nix                # Linux-only session variables (LESSHISTFILE, LESSKEY)
│   ├── scripts.nix              # Utility scripts (output-scale)
│   ├── packages.nix             # Desktop packages (waybar, mpv, discord-ptb, nemo, gvfs, etc.)
│   ├── xdg.nix                  # XDG portal config (xdg-desktop-portal-*)
│   └── zen-browser.nix          # Zen Browser
├── darwin/                      # macOS-only home modules (placeholder)
│   └── default.nix
└── hosts/                       # Host-specific HM overrides
    ├── nixos/
    │   ├── padrick/
    │   │   ├── default.nix      # Imports core + linux, symlinks host configs
    │   │   ├── packages.nix     # btop
    │   │   └── config/          # Host-specific dotfiles (niri, hyprland, noctalia)
    │   │       ├── niri-host-settings.kdl
    │   │       ├── hypr-host-settings.lua
    │   │       └── noctalia-host-settings.toml
    │   └── jobert/
    │       ├── default.nix
    │       ├── packages.nix     # btop-cuda, chromium, prismlauncher
    │       └── config/
    │           ├── niri-host-settings.kdl
    │           ├── hypr-host-settings.lua
    │           └── noctalia-host-settings.toml
    └── darwin/                  # macOS host-specific HM (placeholder)
```

## Module Types

- **`core/`** - Cross-platform user config (shell, packages, editors, terminal). Always imported on all platforms.
- **`linux/`** - Linux-only GUI applications and dotfiles (GTK, Wayland compositors, portals). Only for Linux desktop hosts.
- **`darwin/`** - macOS-only home modules (placeholder). Will contain Aerospace, CmdTap, etc.
- **`hosts/<name>/`** - Host-specific overrides, flake input imports, and hardware config symlinks.

## How It Works

The host's HM entry point (`home/hosts/<name>/default.nix`) imports `core/` and the platform-specific directory (`linux/` or `darwin/`), plus any flake module inputs (niri, noctalia).

Config files in `config/` are consumed by Home Manager modules via `xdg.configFile` store copies. Directories with multiple files (like `hypr/` and `nvim/`) use `recursive = true`. Host-specific settings in `home/hosts/<name>/config/` also use store copies.

The `hostname` is passed via `specialArgs` in `outputs/default.nix`, allowing shared modules like `noctalia.nix` to read host-specific settings.

For niri, the main `config.kdl` uses `include "./niri-host-settings.kdl"` to pull in host-specific settings. For hyprland, `require("hypr-host-settings")` loads the host-specific `hypr-host-settings.lua`. For noctalia, `noctalia.nix` symlinks `config.toml`, generates `wallpaper.toml` (with interpolated paths), and writes `host-settings.toml` with lockscreen widgets from `home/hosts/<name>/config/noctalia-host-settings.toml`.

## Home Manager Backup

If existing files conflict with Home Manager managed files, HM will rename them with a `.hm-bak` extension instead of failing. This is configured in `outputs/default.nix` under the `mkNixosHost` helper:

```nix
home-manager.backupFileExtension = "hm-bak";
```

Clean up `.hm-bak` files manually after verifying the new config works.

## Mounting SMB Shares with Nemo

Nemo is the default file manager. `gvfs` and `nemo-with-extensions` are installed, and `services.gvfs` is enabled system-wide in `modules/nixos/desktop/services.nix`. To mount a share: click `File` > `Connect to Server`, set the type to `Windows share`, enter the details, and connect.

## Adding a Module

1. Create a `.nix` file in `home/core/` (cross-platform) or `home/linux/` (Linux-only)
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
2. Create or update a module in `home/core/` or `home/linux/`:

For a single file:

```nix
{ ... }:

{
  xdg.configFile."app/config".source = ../../config/app/config;
}
```

For a directory with multiple files:

```nix
{ ... }:

{
  xdg.configFile."app" = {
    source = ../../config/app;
    recursive = true;
  };
}
```

3. It will be auto-imported by `scanPaths` in `default.nix`

## Host-Specific Overrides

In `home/hosts/<name>/default.nix`, add host-specific settings after the imports. Hardware config files in `home/hosts/<name>/config/` use store copies:

```nix
{ config, inputs, ... }:

{
  imports = [
    ../../../core
    ../../../linux
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
  xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
}
```

Noctalia lockscreen widget settings can be placed in `home/hosts/<name>/config/noctalia-host-settings.toml`. If present, they are written to `host-settings.toml` in `~/.config/noctalia/` by `home/linux/noctalia.nix` (which uses the `hostname` arg passed from `outputs/default.nix`). Noctalia merges all `*.toml` files alphabetically, so `config.toml` loads first, then `host-settings.toml`, then `wallpaper.toml`.

Add host-specific user packages in `home/hosts/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # user packages only needed on this host
  ];
}
```

## Shell Aliases

All aliases are defined in `home/core/shell.nix` and applied via `home.shellAliases`:

```nix
let
  shellAliases = {
    svim = "sudoedit";
    cat = "bat";
    bldswc = "sudo nixos-rebuild switch";
    bldflk = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
    nixgarb = "sudo nix-collect-garbage";
    sagenix = "sudo agenix -i /etc/ssh/ssh_host_ed25519_key";
    ls = "eza --icons=always --color=always --group-directories-first";
    ll = "eza -alF --icons=always --color=always --group-directories-first";
    lll = "eza -al --icons=always --group-directories-first --git --color-scale=all --color-scale-mode=gradient";
    lt = "eza --tree --level=2 --icons=always --color=always";
  };
in
{
  home.shellAliases = shellAliases;
}
```

`home/linux/shell.nix` contains Linux-only session variables (LESSHISTFILE, LESSKEY).

## Host-Specific Packages

Host-specific user packages live in `home/hosts/<name>/packages.nix`. Shared user packages live in `home/core/packages.nix`.

Examples:
- `padrick`: `btop`
- `jobert`: `btop-cuda`, `chromium`, `prismlauncher`
