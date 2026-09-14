# System Modules

System-level configuration as dendritic `flake.modules.nixos.*` pieces,
organized by platform. Every `.nix` file under `modules/` is auto-imported by
`import-tree` — no aggregator files. Cross-file composition is explicit via
`inputs.self.modules.*`.

## Module Types

- **`base/`** — Cross-platform config (Multi-Context Aspect: same body published as `nixos.*` and `darwin.*`).
- **`nixos/base/`** — Core NixOS pieces (boot, networking, locale, SSH, secrets, firewall). Always imported via the `desktop`/`server` system types.
  - `system.nix` — Boot, networking, GC, `features.system.kernelPackage` option. User identity comes from the `username`/`vars` specialArgs (`flake.lib.vars`); the account itself lives in `users/ize.nix`
  - `locale.nix` — Timezone, locale, hardware clock (UTC)
  - `ssh.nix` — OpenSSH (key-based auth only, root login denied)
  - `secrets.nix` — agenix secret declarations (imports agenix itself; `nix-access-tokens` is `0440 root:wheel` + `!include` with a missing-file fallback so fresh hosts don't deadlock)
  - `security.nix` — Neovim, firewall (base rules), polkit/rtkit
  - `packages.nix` — Base system packages
- **`nixos/desktop.nix`** — `desktop` system type (Inheritance Aspect): base + desktop GUI modules + home-manager wiring. Hosts import `nixos.desktop`.
- **`nixos/desktop/`** — GUI/desktop pieces (greetd, Niri, PipeWire, fonts).
- **`nixos/server.nix`** — `server` system type (Inheritance Aspect): base modules only, no desktop, no Home Manager.
- **`features/`** — Optional functionality as plain composable modules; hosts import what they use (importing IS enabling).
- **`users/`** — The primary user as a reusable Multi-Context feature (`nixos.user-ize` owns the account, `homeManager.user-ize` re-exports `home-base`).

To add a module, create a `.nix` file declaring one `flake.modules.<class>.<name>` piece — `import-tree` picks it up automatically. If it should be composed (system types), also add it to the relevant collector (`desktop`/`server`, `home-linux-core`/`home-linux-gui`). Features need no collector: hosts import them directly.

## Adding a Desktop Host

Hosts compose `nixos.desktop` + `nixos.user-ize` + feature modules in their own `modules/hosts/<name>/configuration.nix` (see `modules/hosts/README.md`):

```nix
imports = [
  nixos.desktop
  nixos.user-ize
  # ...feature modules + host-specific *-pieces + external modules...
];
```

## Adding a Server Host

Compose `nixos.server` instead, and instantiate with `mkNixosServerHost` in the host's `flake-parts.nix` (no home-manager):

```nix
imports = [
  nixos.server
  nixos.user-ize
  ./hardware-configuration.nix
];
```

## Using as an External Module

The `nixosModules.default` output (overlays only — minimal, not the opinionated
`desktop` type) can be consumed by other flakes:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-config.url = "github:ize/nix-config";
  };

  outputs = { self, nixpkgs, nix-config, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit (nix-config.lib) vars;
        username = "myuser";
        hostname = "myhost";
        flakeRoot = nix-config;
        inputs = {
          inherit nixpkgs;
          self = nix-config;
        };
      };
      modules = [
        nix-config.nixosModules.default
        {
          networking.hostName = "myhost";
        }
      ];
    };
  };
}
```

Note: external use requires passing this repo's `specialArgs` (`inputs` with `self` + `nixpkgs`, `flake.lib.vars`, `hostname`, `username`, `flakeRoot`) — see the `mkNixosHost` factory in `modules/dendritic/lib.nix`. `username`/`hostname` are plain strings. Disko is included via the factory's `baseSystemModules`; external use without the factory must also import `inputs.disko.nixosModules.default` if needed.

## Features

Optional functionality lives in `modules/features/` as plain composable modules — **importing one is enabling it**. Each host's `configuration.nix` lists exactly what it uses:

```nix
imports = [
  nixos.btrfs # BTRFS compression/tuning (compress=zstd:3, noatime; device opts in mkDiskoBtrfs)
  nixos.impermanence # Ephemeral root, persistent /persist subvolume (`features.impermanence.rollbackDevice`)
  nixos.secureboot # UEFI Secure Boot via Lanzaboote (requires impermanence)
  nixos.vm-qemu # QEMU/KVM, virt-manager, SPICE
  nixos.vm-bottles # Wine runner
  nixos.vm-dosbox # DOSBox emulator
  nixos.gaming # Steam, Gamescope, Gamemode, MangoHud
  nixos.zswap # Zswap with zstd compression
  nixos.p2p # Syncthing, NetBird VPN, LocalSend (peers/folders via `features.p2p.syncthing.*`; NetBird key auto-persisted when /persist exists)
  nixos.p2p-zerotier # ZeroTier VPN (needs networkId, see below)
  nixos.containers # Podman, Distrobox (Docker disabled)
  nixos.fhs # FHS env + nix-alien for unpatched binaries
];
```

Home-side counterparts live in `modules/home/base/features/` (`home-features-vscode`, `home-features-zed`, `home-features-recording`, `home-features-p2p`) and are composed in each host's `home.nix` the same way.

### P2P + ZeroTier

The `p2p` module configures Syncthing, NetBird (auto-login via agenix setup key), and LocalSend, with firewall ports opened. ZeroTier lives in its own module — import it and set the host-specific network ID:

```nix
imports = [ nixos.p2p-zerotier ];
features.p2p.zerotier.networkId = "88c5b1f339f6593b";
```

### Adding a New Feature

Create `modules/features/<name>.nix` declaring `flake.modules.nixos.<name>`, then import it in the hosts that need it — no flags, no collectors:

```nix
# Dendritic module: flake.modules.nixos.<name>
{
  flake.modules.nixos.<name> =
    { pkgs, ... }:
    {
      # your config here (applied whenever a host imports this module)
    };
}
```

Only add an option if the module needs a host-specific *value* (like `networkId` above) — never an `enable` flag; importing IS enabling.

## Overriding Modules Per Host

Prefer plain assignment in the host collector. `mkDefault` for shared-type
values, `mkForce` only to beat another default:

```nix
{ lib, ... }:

{
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;
  networking.hostName = lib.mkDefault "my-host";
}
```
