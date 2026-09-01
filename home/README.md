# Home Manager Modules

User-level configuration managed by Home Manager, organized by platform.

## Module Types

- **`core/`** — Cross-platform (shell, packages, editors, terminal). Always imported.
- **`linux/`** — Linux-only GUI apps and dotfiles (GTK, Wayland compositors, portals).
- **`darwin/`** — macOS-only home modules (placeholder).
- **`hosts/<name>/`** — Host-specific overrides, flake input imports, and hardware config symlinks.

All directories use `scanPaths` for auto-import — create a `.nix` file and it's picked up automatically.

## How It Works

The host's HM entry point (`home/hosts/<name>/default.nix`) imports `core/` and the platform directory (`linux/` or `darwin/`), plus flake module inputs (niri, noctalia).

Config files in `config/` are consumed via `xdg.configFile` store copies. Host-specific settings in `home/hosts/<name>/config/` also use store copies. The `hostname` is passed via `specialArgs`, allowing modules like `noctalia.nix` to read host-specific settings.

## Home Manager Backup

HM renames conflicting files with `.hm-bak` instead of failing (`home-manager.backupFileExtension = "hm-bak"` in `outputs/default.nix`). Clean up after verifying.

## Adding a Module

Create a `.nix` file in `home/core/` or `home/linux/`:

```nix
{ pkgs, ... }:

{
  programs.<name> = {
    enable = true;
    # options...
  };
}
```

It will be auto-imported by `scanPaths` in `default.nix`.

## Host-Specific Overrides

In `home/hosts/<name>/default.nix`, add host-specific settings after the imports:

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

Noctalia lockscreen widgets go in `home/hosts/<name>/config/noctalia-host-settings.toml`. If present, `noctalia.nix` writes it to `host-settings.toml` in `~/.config/noctalia/`. TOML files merge alphabetically: `config.toml` → `host-settings.toml` → `wallpaper.toml`.

Add host-specific user packages in `home/hosts/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # user packages only needed on this host
  ];
}
```

## Host-Specific Packages

- **padrick**: `btop`
- **jobert**: `btop-cuda`, `chromium`, `prismlauncher`
