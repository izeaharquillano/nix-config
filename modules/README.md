# System Modules

System-level configuration as dendritic `flake.modules.nixos.*` pieces,
organized by platform. Every `.nix` file under `modules/` is auto-imported by
`import-tree` — no aggregator files. Cross-file composition is explicit via
`inputs.self.modules.*`.

## Module Types

- **`base/`** — Cross-platform config (Multi-Context Aspect: same body published as `nixos.*` and `darwin.*`).
- **`nixos/base/`** — Core NixOS pieces (boot, networking, locale, SSH, secrets, firewall). Always imported via the `desktop`/`server` system types.
  - `system.nix` — Boot, networking, GC, `mySystem.kernelPackage` and `mySystem.username` options (the user account itself lives in `users/ize.nix`)
  - `locale.nix` — Timezone, locale, hardware clock (UTC)
  - `ssh.nix` — OpenSSH (key-based auth only, root login denied)
  - `secrets.nix` — agenix secret declarations
  - `security.nix` — Neovim, firewall (base rules), polkit/rtkit
  - `packages.nix` — Base system packages
- **`nixos/desktop.nix`** — `desktop` system type (Inheritance Aspect): base + desktop GUI modules + home-manager wiring. Hosts import `nixos.desktop`.
- **`nixos/desktop/`** — GUI/desktop pieces (greetd, Niri, PipeWire, fonts).
- **`nixos/server.nix`** — `server` system type (Inheritance Aspect): base modules only, no desktop, no Home Manager.
- **`features/`** — Optional features gated behind `mkEnableOption` (Conditional Aspect), collected by `features.nix` (Collector Aspect).
- **`users/`** — The primary user as a reusable Multi-Context feature (`nixos.user-ize` owns the account, `homeManager.user-ize` re-exports `home-base`).

To add a module, create a `.nix` file declaring one `flake.modules.<class>.<name>` piece — `import-tree` picks it up automatically. If it should be composed (system types, features), also add it to the relevant collector (`desktop`/`server`, `features.nix`, `home-linux-core`/`home-linux-gui`, `home-features`).

## Adding a Desktop Host

Hosts compose `nixos.desktop` + `nixos.features` + `nixos.user-ize` in their own `modules/hosts/<name>/configuration.nix` (see `modules/hosts/README.md`):

```nix
imports = [
  nixos.desktop
  nixos.features
  nixos.user-ize
  # ...host-specific *-pieces + external modules...
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

The `nixosModules.default` output (desktop system type + all features, plus overlays and `mySystem` defaults) can be consumed by other flakes:

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
          mySystem.username = "myuser";
          networking.hostName = "myhost";
        }
      ];
    };
  };
}
```

Note: external use requires passing this repo's `specialArgs` (`inputs`, `mylib`/`flake.lib.mylib`, `myvars`/`flake.lib.vars`, `hostname`, `username`, `flakeRoot`) — see the `mkNixosHost` factory in `modules/dendritic/lib.nix`.

## Feature Options

Enable optional features in `modules/hosts/<name>/configuration.nix`:

```nix
features = {
  btrfs.enable = true;       # BTRFS compression/tuning (compress=zstd:3, noatime, ssd)
  impermanence.enable = true; # Ephemeral root, persistent /persist subvolume
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM, virt-manager, SPICE, Bottles, DOSBox
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing, NetBird VPN, LocalSend
  containers.enable = true;  # Docker (rootless), Podman, Distrobox
  fhs.enable = true;         # FHS env + nix-alien for unpatched binaries
  editors.enable = true;     # Heavy code editors (VSCode, Zed)
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

### VM Feature

The `vm` feature module configures QEMU/KVM, virt-manager, SPICE tools, Bottles, and DOSBox. QEMU and Bottles default to `true`, DOSBox defaults to `false`:

```nix
features.vm = {
  enable = true;
  qemu.enable = true;     # libvirtd, QEMU/KVM, virt-manager, SPICE (default: true)
  bottles.enable = true;  # Wine runner (default: true)
  dosbox.enable = true;   # DOSBox emulator (default: false)
};
```

### Editors Feature

The `editors` feature module configures heavy code editors. VSCode defaults to `true`, Zed defaults to `false`:

```nix
features.editors = {
  enable = true;
  vscode.enable = true;   # VS Code with extensions and settings (default: true)
  zed.enable = true;      # Zed Editor (default: false)
};
```

### Adding a New Feature

Create `modules/features/<name>.nix` declaring `flake.modules.nixos.<name>`, then add it to the `features` collector in `modules/features/features.nix` (both steps — `import-tree` imports the file, the collector composes it):

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

Use `lib.mkForce` or `lib.mkDefault` in `modules/hosts/<name>/configuration.nix`:

```nix
{ lib, ... }:

{
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;
  networking.hostName = lib.mkDefault "my-host";
}
```
