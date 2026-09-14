# Modules

Dendritic `flake.modules.<class>.<name>` pieces, grouped by **domain**
(following [Doc-Steve's dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts):
`programs/` / `services/` / `system/` / `users/` / `hosts/` / `nix/`).
Every `.nix` file under `modules/` is auto-imported by `import-tree` —
no aggregator files. File paths are documentation only; the aspect name
(`flake.modules.<class>.<name>`) is the glue. Cross-file composition is
explicit via `inputs.self.modules.*`.

## Domain Groups

- **`nix/`** — Flake infra (was `dendritic/` + `tools/` + `base/nix.nix` bits).
  `flake-parts.nix` (module registry), `lib.nix` (vars, `mkNixosHost`,
  `mkDiskoBtrfs`), `darwin-fix.nix`, plus per-system wiring:
  `home-manager.nix`, `nixpkgs.nix`, `overlays.nix`, `packages.nix`,
  `treefmt.nix`. Also `system/nix.nix` (`nixos.nix` + `darwin.nix`
  Multi-Context Aspect: shared nix settings) and `system/direnv.nix`.
- **`system/`** — OS foundation. Always imported via the `desktop`/`server`
  system types in `system/types/` (Inheritance Aspect).
  - `nix.nix`, `direnv.nix`, `locale.nix`, `system.nix` (boot, networking,
    GC, `features.system.kernelPackage` option), `packages.nix`,
    `secrets.nix` (agenix; `0440 root:wheel` + `!include` fallback),
    `security.nix` (neovim, firewall, polkit/rtkit)
  - `storage/` — `btrfs.nix`, `impermanence.nix`
  - `boot/` — `secureboot.nix` (Lanzaboote, requires impermanence),
    `zswap.nix`
  - `types/` — `desktop.nix` (`nix` + `direnv` + `system` + `locale` +
    `ssh` + `secrets` + `security` + `packages` + `greetd` + `niri` +
    `hyprland` + `desktop-services` + `home-manager`), `server.nix`
    (core only, no desktop, no HM), `linux-core.nix` (headless HM:
    `user-ize` + `shell` + `cli` + `dev` + `terminal` + `nvim`),
    `linux-gui.nix` (full GUI HM: `linux-core` + `linux-desktop` +
    `linux-utils` + `apps` + `web` + `hyprland` + `niri` + `noctalia` +
    `notes`). Hosts import ONE system type + features.
- **`services/`** — System daemons (`services.*`, `virtualisation.*`,
  firewall). `ssh.nix`, `greetd.nix`, `desktop.nix` (PipeWire, fonts,
  bluetooth), `containers.nix` (Podman/Distrobox), `zerotier.nix`
  (needs `features.p2p.zerotier.networkId`), and `p2p/` as a **feature
  closure**: `nixos.p2p` (Syncthing/NetBird/LocalSend) + `homeManager.p2p`
  (tray) in one dir.
- **`programs/`** — User-facing apps (`programs.*`, HM `programs.*`,
  app bundles). Feature closures where a feature spans both classes:
  `desktop/hyprland/` (`nixos.hyprland` + `homeManager.hyprland`) and
  `desktop/niri/` (`nixos.niri` + `homeManager.niri`) in one dir each.
  - `desktop/` — `hyprland/`, `niri/`, `noctalia.nix`, `apps.nix`,
    `web.nix` (Zen), `notes.nix` (Obsidian), `linux-desktop.nix` (XDG/Nemo/GTK)
  - `shell/` — `shell.nix`, `cli.nix`, `terminal.nix` (kitty), `utils.nix`
  - `dev/` — `dev.nix` (git/lazygit/npm), `nvim.nix`, `vscode.nix`, `zed.nix`
  - `media/` — `recording.nix` (OBS)
  - `gaming.nix`, `virtualisation/` (`vm-qemu`, `vm-bottles`, `vm-dosbox`),
    `compat/fhs.nix`
- **`users/`** — The primary user as a reusable Multi-Context feature
  (`nixos.user-ize` owns the account, `homeManager.user-ize` re-exports
  `home-base`). User identity comes from the `username`/`vars` specialArgs
  (`flake.lib.vars`).
- **`hosts/`** — Per-host composition roots (see `hosts/README.md`):
  `configuration.nix` composes `nixos.desktop`/`nixos.server` +
  `nixos.user-ize` + features, `home.nix` composes `linux-gui`/`linux-core`
  + features, `flake-parts.nix` instantiates via `mkNixosHost`.

To add a module, create a `.nix` file declaring one
`flake.modules.<class>.<name>` piece — `import-tree` picks it up
automatically. If it should be composed (system types), also add it to the
relevant collector (`desktop`/`server`, `linux-core`/`linux-gui`).
Features need no collector: hosts import them directly. If a feature spans
NixOS + Home Manager, put BOTH aspects in one domain dir
(e.g. `services/p2p/default.nix`, `programs/desktop/niri/default.nix`) —
never split `features/` vs `home/.../features/` again.

Aspect naming: the feature name is shared across classes
(`nixos.niri` + `homeManager.niri` = the `niri` feature;
`nixos.p2p` + `homeManager.p2p` = the `p2p` feature). No
`home-features-*` / `home-gui-*` / `home-core-*` / `base-*` /
`desktop-*` prefixes.

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

Note: external use requires passing this repo's `specialArgs` (`inputs` with `self` + `nixpkgs`, `flake.lib.vars`, `hostname`, `username`, `flakeRoot`) — see the `mkNixosHost` factory in `modules/nix/lib.nix`. `username`/`hostname` are plain strings. Disko is included via the factory's `baseSystemModules`; external use without the factory must also import `inputs.disko.nixosModules.default` if needed.

## Features

Optional functionality lives in `services/` + `programs/` as plain composable modules — **importing one is enabling it**. Each host's `configuration.nix` lists exactly what it uses:

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
  nixos.zerotier # ZeroTier VPN (needs networkId, see below)
  nixos.containers # Podman, Distrobox (Docker disabled)
  nixos.fhs # FHS env + nix-alien for unpatched binaries
];
```

Home-side pieces (`vscode`, `zed`, `recording`, `p2p`) live alongside their
domain siblings under `programs/` + `services/` and are composed in each
host's `home.nix` the same way (`linux-gui` + `vscode` + `recording` + `p2p`).

### P2P + ZeroTier

The `p2p` feature configures Syncthing, NetBird (auto-login via agenix setup key), and LocalSend, with firewall ports opened (HM tray in the same `services/p2p/` dir). ZeroTier lives in its own module — import it and set the host-specific network ID:

```nix
imports = [ nixos.zerotier ];
features.p2p.zerotier.networkId = "88c5b1f339f6593b";
```

### Adding a New Feature

Create `modules/services/<name>.nix` (daemon) or `modules/programs/<group>/<name>.nix` (app) declaring `flake.modules.nixos.<name>` (and `flake.modules.homeManager.<name>` in the SAME file/dir if it spans both — feature closure), then import it in the hosts that need it — no flags, no collectors:

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
