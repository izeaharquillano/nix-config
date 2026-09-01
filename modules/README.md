# System Modules

System-level configuration split into reusable modules, organized by platform.

## Module Types

- **`nixos/core/`** — Base NixOS config (boot, networking, nix, users, SSH, firewall). Always imported.
  - `system.nix` — Boot, networking, nix settings, `mySystem.kernelPackage` and `mySystem.username` options
  - `locale.nix` — Timezone, locale, hardware clock (UTC)
  - `ssh.nix` — OpenSSH (key-based auth only, root login denied)
  - `secrets.nix` — agenix secret declarations
  - `security.nix` — Neovim, nix-ld, firewall (base rules)
  - `packages.nix` — Base system packages
- **`nixos/desktop/`** — GUI/desktop config (greetd, Niri, PipeWire, fonts). Only for desktop hosts.
- **`nixos/features/`** — Optional features gated behind `mkEnableOption`. Auto-imported via `scanPaths`.
- **`darwin/`** — macOS system config (placeholder).

All directories use `scanPaths` for auto-import — create a `.nix` file and it's picked up automatically.

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
          specialArgs = {
            hostname = "myhost";
            username = "myuser";
            flakeRoot = ./.;
            inputs = inputs;
            mylib = nixos-conf.legacyPackages.x86_64-linux.mylib or {};
          };

          mySystem.username = "myuser";
          networking.hostName = "myhost";
        }
      ];
    };
  };
}
```

## Feature Options

Enable optional features in `hosts/nixos/<name>/default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS compression/tuning (compress=zstd:3, noatime, ssd)
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird VPN
  docker.enable = true;      # Docker (rootless, auto-prune)
};
```

### P2P Feature

The `p2p` feature module configures Syncthing and NetBird. Enable with `myfeatures.p2p.enable = true`. This opens UDP 51820 for NetBird WireGuard, enables Syncthing with default sync/discovery ports, and auto-starts NetBird via setup key.

### Adding a New Feature

Create `modules/nixos/features/<name>.nix`. It's auto-imported by `scanPaths`:

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

Use `lib.mkForce` or `lib.mkDefault` in `hosts/nixos/<name>/default.nix`:

```nix
{ lib, ... }:

{
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;
  networking.hostName = lib.mkDefault "my-host";
}
```
