# NixOS Modules

System-level NixOS configuration split into reusable modules.

## Structure

```
modules/
├── core/                # Shared by ALL hosts (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (auto-imported via scanPaths)
│   ├── system.nix       # Boot (latest kernel), networking, nix settings, user accounts
│   ├── locale.nix       # Timezone, i18n/locale settings, hardware clock (UTC)
│   ├── ssh.nix          # OpenSSH (key-based auth only, root login denied)
│   ├── secrets.nix      # agenix secret declarations (age key config, secrets)
│   ├── security.nix     # Neovim, nix-ld, firewall
│   └── packages.nix     # System-wide packages
├── desktop/             # Desktop environment (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (auto-imported via scanPaths)
│   ├── greetd.nix       # Login manager (tuigreet)
│   ├── niri.nix         # Niri Wayland compositor
│   └── services.nix     # blueman, fwupd, pipewire, bluetooth, gvfs, zsh, hyprland, fonts
├── features/            # Optional feature modules (mkEnableOption, auto-imported)
│   ├── default.nix      # Aggregator (auto-imported via scanPaths)
│   ├── btrfs.nix        # BTRFS compression/tuning options (myfeatures.btrfs.enable)
│   ├── secureboot.nix   # UEFI Secure Boot (myfeatures.secureboot.enable)
│   ├── vm.nix           # QEMU/KVM + virt-manager (myfeatures.vm.enable)
│   ├── gaming.nix       # Steam, Gamescope, Gamemode (myfeatures.gaming.enable)
│   ├── zswap.nix        # Zswap with zstd compression (myfeatures.zswap.enable)
│   └── p2p.nix          # Syncthing + NetBird (myfeatures.p2p.enable)
```

## Module Types

- **`core/`** - Base system config (boot, networking, nix, users, SSH, firewall) every host needs. Always imported.
  - `system.nix` sets `boot.kernelPackages` via the `mySystem.kernelPackage` option (default: `linuxPackages_7_2`). Hosts can override this in their `hardware.nix`.
  - `system.nix` defines `mySystem.username` — the single source of truth for the primary user. Set by `flake.nix` via `mySystem.username = username;`.
  - `locale.nix` sets `time.hardwareClockInLocalTime = false` (RTC in UTC). See the main README for dual-boot Windows instructions.
  - `ssh.nix` enables OpenSSH with key-based auth only.
  - `security.nix` enables Neovim, nix-ld, and the firewall.
- **`desktop/`** - GUI/desktop config. Only imported by desktop hosts.
- **`features/`** - Optional features gated behind `mkEnableOption`. Auto-imported via `scanPaths`; enable per host with `myfeatures.<name>.enable`.

## Using as an External Module

The `nixosModules.default` output can be consumed by other flakes:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-conf.url = "github:ize/nixos-conf";
  };

  outputs = { self, nixpkgs, nixos-conf, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-conf.nixosModules.default
        {
          # Required: set specialArgs for the modules
          specialArgs = {
            hostname = "myhost";
            username = "myuser";
            flakeRoot = ./.;
            inputs = inputs;
            mylib = nixos-conf.legacyPackages.x86_64-linux.mylib or {};
          };

          # Optional: override defaults
          mySystem.username = "myuser";
          mySystem.kernelPackage = pkgs.linuxPackages_latest;

          networking.hostName = "myhost";
        }
      ];
    };
  };
}
```

The module sets up the overlay and provides defaults for `mySystem.username` and `mySystem.kernelPackage`.

## Feature Options

Enable optional features in `hosts/<name>/default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS compression/tuning options (compress=zstd:3, noatime, ssd)
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird VPN
};
```

### P2P Feature

The `p2p` feature module (`modules/features/p2p.nix`) configures Syncthing and NetBird. Enable it per host:

```nix
myfeatures.p2p.enable = true;
```

This enables:
- **Syncthing** with default ports open for sync and discovery
- **NetBird** VPN with automatic login via setup key (`/etc/netbird/setup-key`)

Syncthing paths use `config.users.users.${config.mySystem.username}.home` dynamically rather than hardcoded paths.

### Adding a new feature

Create `modules/features/<name>.nix`. It's auto-imported by `scanPaths`:

```nix
{ pkgs, lib, config, ... }:

let
  cfg = config.myfeatures.<name>;
in
{
  options.myfeatures.<name> = {
    enable = lib.mkEnableOption "Description of the feature";
  };

  config = lib.mkIf cfg.enable {
    # your config here
  };
}
```

## Overriding Modules Per Host

In `hosts/<name>/default.nix`, use `lib.mkForce` or `lib.mkDefault` to override:

```nix
{ lib, ... }:

{
  # Disable syncthing and netbird (modules/features/p2p.nix)
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;

  # Override hostname
  networking.hostName = lib.mkDefault "my-host";
}
```
