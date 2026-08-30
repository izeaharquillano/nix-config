# Home Manager Modules

User-level configuration managed by Home Manager.

## Structure

```
home/
├── core/                    # Shared across all hosts
│   ├── default.nix          # Aggregator + stateVersion, username
│   ├── shell.nix            # Bash, zsh, git, starship, zoxide, aliases (shared via let)
│   ├── packages.nix         # CLI tools (fd, fzf, btop, ripgrep, opencode, etc.)
│   └── xdg.nix              # XDG user directories + portal config
├── desktop/                 # Desktop/GUI app configs
│   ├── default.nix          # Aggregator
│   ├── gtk.nix              # GTK theme, cursor
│   ├── terminal.nix         # Kitty terminal (package + live symlink)
│   ├── hyprland.nix         # Hyprland config (store copy, recursive)
│   ├── niri.nix             # Niri config (live symlink for config.kdl)
│   ├── noctalia.nix         # Noctalia lockscreen/bar (config.toml + wallpaper.toml + host-settings.toml)
│   ├── nvim.nix             # Neovim LazyVim config (store copy, recursive)
│   ├── mimeapps.nix         # Nemo desktop entry + MIME associations
│   ├── obsidian.nix         # Obsidian
│   ├── scripts.nix          # Utility scripts (output-scale)
│   ├── starship.nix         # Starship prompt (live symlink for starship.toml)
│   ├── yazi.nix             # Yazi file manager + gruvbox theme
│   ├── tmux.nix             # Tmux config (live symlink for tmux.conf)
│   ├── packages.nix         # Desktop packages (ncdu, waybar, mpv, discord-ptb, nemo, gvfs, etc.)
│   └── zen-browser.nix      # Zen Browser
└── hosts/
    ├── padrick/
    │   ├── default.nix      # Host-specific HM: imports core + desktop, live-symlinks host configs
    │   ├── packages.nix     # btop
    │   └── config/          # Host-specific dotfiles (niri, hyprland, noctalia)
    │       ├── niri-host-settings.kdl
    │       ├── hypr-host-settings.lua
    │       └── noctalia-host-settings.toml
    └── jobert/
        ├── default.nix
        ├── packages.nix     # btop-cuda, chromium, prismlauncher
        └── config/
            ├── niri-host-settings.kdl
            ├── hypr-host-settings.lua
            └── noctalia-host-settings.toml
```

## Module Types

- **`core/`** - Essential user config (shell, packages). Always imported.
- **`desktop/`** - GUI applications and dotfiles. Only for desktop hosts.
- **`hosts/<name>/`** - Host-specific overrides, flake input imports, and hardware config symlinks.

## How It Works

The host's HM entry point (`home/hosts/<name>/default.nix`) imports `core/` and `desktop/`, plus any flake module inputs (niri, noctalia).

Individual config files in `config/` are live-symlinked into `~/.config/` via `config.lib.file.mkOutOfStoreSymlink`. This means edits to config files take effect immediately without a rebuild. Each module constructs the symlink target as `${config.home.homeDirectory}/nixos-conf/config/<app>`.

Directories with multiple files (like `hypr/` and `nvim/`) use store copies with `recursive = true` instead, because `mkOutOfStoreSymlink` on a directory conflicts with HM's file management when other modules also create files inside that directory. Host-specific settings in `home/hosts/<name>/config/` use store copies for the same reason.

The `hostname` is passed via `specialArgs` in `flake.nix`, allowing shared modules like `noctalia.nix` to read host-specific settings.

For niri, the main `config.kdl` uses `include "./niri-host-settings.kdl"` to pull in host-specific settings. For hyprland, `require("hypr-host-settings")` loads the host-specific `hypr-host-settings.lua`. For noctalia, `noctalia.nix` symlinks `config.toml`, generates `wallpaper.toml` (with interpolated paths), and writes `host-settings.toml` with lockscreen widgets from `home/hosts/<name>/config/noctalia-host-settings.toml`.

## Home Manager Backup

If existing files conflict with Home Manager managed files, HM will rename them with a `.hm-bak` extension instead of failing. This is configured in `flake.nix` under the `mkHost` helper:

```nix
home-manager.backupFileExtension = "hm-bak";
```

Clean up `.hm-bak` files manually after verifying the new config works.

## Mounting SMB Shares with Nemo

Nemo is the default file manager. `gvfs` and `nemo-with-extensions` are installed, and `services.gvfs` is enabled system-wide in `modules/desktop/services.nix`. To mount a share: click `File` > `Connect to Server`, set the type to `Windows share`, enter the details, and connect.

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

For a single file (live symlink, edits take effect immediately):

```nix
{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."app/config".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/app/config";
}
```

For a directory with multiple files (store copy, requires rebuild):

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

Noctalia lockscreen widget settings can be placed in `home/hosts/<name>/config/noctalia-host-settings.toml`. If present, they are written to `host-settings.toml` in `~/.config/noctalia/` by `home/desktop/noctalia.nix` (which uses the `hostname` arg passed from `flake.nix`). Noctalia merges all `*.toml` files alphabetically, so `config.toml` loads first, then `host-settings.toml`, then `wallpaper.toml`.

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

Aliases are defined in `home/core/shell.nix` using a `let` binding to avoid duplication between bash and zsh:

```nix
let
  sharedAliases = {
    svim = "sudoedit";
    cat = "bat";
    bldswc = "sudo nixos-rebuild switch";
    bldflk = "sudo nixos-rebuild switch --flake ~/nixos-conf#$(hostname)";
    nixgarb = "sudo nix-collect-garbage";
  };

  zshAliases = sharedAliases // {
    ls = "eza --icons=always --color=always --group-directories-first";
    ll = "eza -alF --icons=always --color=always --group-directories-first";
    lt = "eza --tree --level=2 --icons=always --color=always";
  };
in
{
  programs.bash.shellAliases = sharedAliases;
  programs.zsh.shellAliases = zshAliases;
}
```

## Host-Specific Packages

Host-specific user packages live in `home/hosts/<name>/packages.nix`. Shared user packages live in `home/core/packages.nix`.

Examples:
- `padrick`: `btop`
- `jobert`: `btop-cuda`, `chromium`, `prismlauncher`
