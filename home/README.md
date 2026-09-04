# Home Manager Modules

User-level configuration managed by Home Manager, organized by platform.

## Module Types

- **`base/`** — Cross-platform base configs shared between Linux and macOS.
  - `core/` — Shell, CLI tools, editors, terminal (always imported).
  - `features/` — Toggleable features that read from `osConfig.features.*`.
  - `home.nix` — Username, stateVersion, homeDirectory.
- **`linux/`** — Linux-specific home modules.
  - `base/` — Linux-only essentials (desktop env, wayland utils).
  - `gui/` — Full Linux GUI (WM configs, apps, browsers, media).
  - `core.nix` — Entry point for headless Linux: imports `base/core` + `base/home.nix` + `linux/base`.
  - `gui.nix` — Entry point for Linux GUI: imports `base/core` + `base/home.nix` + `linux/base` + `linux/gui`.
- **`darwin/`** — macOS-only home modules (placeholder).
- **`hosts/<name>/`** — Host-specific overrides, flake input imports, and hardware config symlinks.

## Entry Points

| Host Type | HM Entry Point | Composes |
|---|---|---|
| Desktop (GUI) | `home/hosts/nixos/<name>.nix` → `linux/gui.nix` | base/core + base/home.nix + linux/base + linux/gui |
| Server (headless) | `home/hosts/nixos/<name>.nix` → `linux/core.nix` | base/core + base/home.nix + linux/base |
| macOS | `home/hosts/darwin/<name>.nix` | TBD |

## How It Works

The host's HM entry point (`home/hosts/<name>/default.nix`) imports the platform entry point (`linux/gui.nix` or `linux/core.nix`), plus `features/`, host-specific packages, and flake module inputs (niri, noctalia).

Config files in `config/` are consumed via `xdg.configFile` store copies. Host-specific settings in `home/hosts/<name>/config/` also use store copies. The `hostname` is passed via `specialArgs`, allowing modules like `noctalia.nix` to read host-specific settings.

## Home Manager Backup

HM renames conflicting files with `.hm-bak` instead of failing (`home-manager.backupFileExtension = "hm-bak"` in `outputs/default.nix`). Clean up after verifying.

## Adding a Module

Create a `.nix` file in `home/base/core/` (cross-platform) or `home/linux/gui/` (Linux GUI):

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

In `home/hosts/nixos/<name>/default.nix`, add host-specific settings after the imports:

```nix
{ config, inputs, ... }:

{
  imports = [
    ../../../linux/gui.nix
    ../../../base/features
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
