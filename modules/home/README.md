# Home Manager Modules

User-level configuration as dendritic `flake.modules.homeManager.*` pieces,
organized by platform. Auto-imported by `import-tree`; composed explicitly via
`inputs.self.modules.homeManager`.

## Module Types

- **`base/`** — Cross-platform base configs shared between Linux and macOS.
  - `core/` — Shell, CLI tools, editors, terminal (`home-core-*` pieces).
  - `features/` — Toggleable features that read from `osConfig.features.*` (`home-features-*` pieces, collected by `features.nix` → `home-features`).
  - `home.nix` — Username, stateVersion, homeDirectory (`home-base`, re-exported by the `user-ize` feature).
- **`linux/`** — Linux-specific home modules.
  - `base/` — Linux-only essentials (`home-linux-desktop`, `home-linux-utils`).
  - `gui/` — Full Linux GUI (`home-gui-*`: apps, Zen Browser, Hyprland, Niri, Noctalia).
  - `core.nix` — `home-linux-core` system type (Inheritance Aspect) for headless Linux.
  - `gui.nix` — `home-linux-gui` system type (Inheritance Aspect) for Linux GUI.
- **`users/ize.nix`** (top level) — the `user-ize` home half re-exports `home-base`.

## Entry Points

| Host Type | HM Composition | Includes |
|---|---|---|
| Desktop (GUI) | `home-linux-gui` + `home-features` (in the host's `home.nix`) | user + core + linux/base + linux/gui + osConfig-driven features |
| Server (headless) | `home-linux-core` | user + core + linux/base |

## How It Works

The host's HM composition root (`modules/hosts/<name>/home.nix`, defining `flake.modules.homeManager.<name>`) imports the platform system type (`home-linux-gui` or `home-linux-core`), plus `home-features`, host-specific packages, and flake module inputs (niri, noctalia).

Config files in `config/` are consumed via `xdg.configFile` store copies referenced through the `flakeRoot` specialArg. Host-specific settings in `modules/hosts/<name>/config/` also use store copies. The `hostname` is passed via `extraSpecialArgs`, allowing modules like `noctalia.nix` to read host-specific settings.

## Home Manager Backup

HM renames conflicting files with `.hm-bak` instead of failing (`home-manager.backupFileExtension = "hm-bak"` in `modules/dendritic/lib.nix`). Clean up after verifying.

## Adding a Module

Create a `.nix` file in `modules/home/base/core/` (cross-platform) or `modules/home/linux/gui/` (Linux GUI) declaring one `flake.modules.homeManager.*` piece:

```nix
# Dendritic module: flake.modules.homeManager.home-core-<name>
{
  flake.modules.homeManager.home-core-<name> =
    { pkgs, ... }:
    {
      programs.<name> = {
        enable = true;
        # options...
      };
    };
}
```

It is picked up by `import-tree` automatically; add it to the relevant collector (`home-linux-core`/`home-linux-gui` in `modules/home/linux/`, or `home-features` in `modules/home/base/features.nix`) so hosts compose it.

## Host-Specific Overrides

In `modules/hosts/<name>/home.nix`, add host-specific settings after the imports:

```nix
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.<name> =
    { inputs, ... }:
    {
      imports = [
        hm.home-linux-gui
        hm.home-features
        hm.<name>-home-packages
        inputs.niri.homeModules.niri
        inputs.noctalia.homeModules.default
      ];

      xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
      xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
    };
}
```

Noctalia lockscreen widgets go in `modules/hosts/<name>/config/noctalia-host-settings.toml`. If present, `noctalia.nix` writes it to `host-settings.toml` in `~/.config/noctalia/`. TOML files merge alphabetically: `config.toml` → `host-settings.toml` → `wallpaper.toml`.

Add host-specific user packages in `modules/hosts/<name>/home-packages.nix` (declaring `flake.modules.homeManager.<name>-home-packages`):

```nix
{
  flake.modules.homeManager.<name>-home-packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # user packages only needed on this host
      ];
    };
}
```

## Host-Specific Packages

- **padrick**: `btop`
- **jobert**: `btop-cuda`, `chromium`, `prismlauncher`
