# System Modules

System-level configuration split into reusable modules, organized by platform.

## Module Types

- **`base/`** — Cross-platform NixOS config (nix settings, direnv). Shared between NixOS and Darwin.
- **`nixos/base/`** — Core NixOS config (boot, networking, nix, users, SSH, firewall). Always imported.
  - `system.nix` — Boot, networking, nix settings, `mySystem.kernelPackage` and `mySystem.username` options
  - `locale.nix` — Timezone, locale, hardware clock (UTC)
  - `ssh.nix` — OpenSSH (key-based auth only, root login denied)
  - `secrets.nix` — agenix secret declarations
  - `security.nix` — Neovim, nix-ld, firewall (base rules)
  - `packages.nix` — Base system packages
- **`nixos/desktop.nix`** — Entry point for desktop/GUI hosts. Imports `nixos/base/` + `nixos/desktop/`.
- **`nixos/desktop/`** — GUI/desktop modules (greetd, Niri, PipeWire, fonts).
- **`nixos/server/`** — Entry point for headless server hosts. Imports `nixos/base/` + server-specific modules.
- **`features/`** — Optional features gated behind `mkEnableOption`. Auto-imported via `scanPaths`.
- **`darwin/`** — macOS system config (placeholder).

All directories use `scanPaths` for auto-import — create a `.nix` file and it's picked up automatically.

## Adding a Desktop Host

Import `modules/nixos/desktop.nix` (which layers `nixos/base/` + `nixos/desktop/`):

```nix
imports = [
  ../../../modules/nixos/desktop.nix
  ../../../modules/features
  ./hardware-configuration.nix
];
```

## Adding a Server Host

Import `modules/nixos/server` (which layers `nixos/base/` + server modules):

```nix
imports = [
  ../../../modules/nixos/server
  ./hardware-configuration.nix
];
```

Then register with `mkNixosServerHost` in `outputs/default.nix` (no home-manager).

## Using as an External Module

The `nixosModules.default` output can be consumed by other flakes:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-config.url = "github:ize/nix-config";
  };

  outputs = { self, nixpkgs, nix-config, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nix-config.nixosModules.default
        {
          specialArgs = {
            hostname = "myhost";
            username = "myuser";
            flakeRoot = ./.;
            inputs = inputs;
            mylib = nix-config.legacyPackages.x86_64-linux.mylib or {};
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
features = {
  btrfs.enable = true;       # BTRFS compression/tuning (compress=zstd:3, noatime, ssd)
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM, virt-manager, Bottles, DOSBox
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing, NetBird VPN, LocalSend
  docker.enable = true;      # Docker (rootless, auto-prune)
  fhs.enable = true;         # FHS env + nix-alien for unpatched binaries
  editors.enable = true;     # Heavy code editors (VSCode, etc.)
  recording.enable = true;   # OBS Studio and recording software
};
```

### P2P Feature

The `p2p` feature module configures Syncthing, NetBird, LocalSend, and optionally ZeroTier. Enable with `features.p2p.enable = true`. This opens UDP 51820 for NetBird WireGuard, enables Syncthing with default sync/discovery ports, auto-starts NetBird via setup key, and enables LocalSend with firewall access.

ZeroTier is optional via a sub-option:

```nix
features.p2p = {
  enable = true;
  zerotier = {
    enable = true;
    networkId = "8056c2e21c123456";
  };
};
```

### Adding a New Feature

Create `modules/features/<name>.nix`. It's auto-imported by `scanPaths`:

```nix
{ pkgs, lib, config, ... }:

let
  cfg = config.features.<name>;
in
{
  options.features.<name> = {
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
