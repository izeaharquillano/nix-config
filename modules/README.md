# Modules

Dendritic `flake.modules.<class>.<name>` pieces, grouped by **domain** (following [Doc-Steve's dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)): programs/, services/, system/, users/, hosts/, nix/.

Every `.nix` file under `modules/` is auto-imported by import-tree — no aggregator files. File paths are documentation only; the aspect name (`flake.modules.<class>.<name>`) is the glue. Cross-file composition is explicit via `inputs.self.modules.*`.

## Domain Groups

### `nix/` — flake infrastructure

- `flake-parts.nix` — module registry
- `lib.nix` — the shared library: vars (including stateVersion), the minimal mkNixosHost / mkDarwinHost factories (mkNixosServerHost is an alias — headless just means no HM user binding in `configuration.nix`), mkDiskoBtrfs, sharedOverlays, shared specialArgs, and mkHostConfigFiles
- `darwin-fix.nix`
- Per-system wiring: home-manager.nix (HM settings + extraSpecialArgs forwarding; the HM user binding lives in each host's `configuration.nix`), nixpkgs.nix, overlays.nix, packages.nix, treefmt.nix

### `system/` — OS foundation

Always imported through the desktop/server system types in `system/types/` (Inheritance Aspect).

- Top-level modules:
  - `nix.nix` (Multi-Context: nixos.nix + darwin.nix, shared nix settings), `direnv.nix`, `locale.nix`
  - `system.nix` — boot, networking, GC, and the `features.system.kernelPackage` option
  - `packages.nix`
  - `secrets.nix` — agenix; `0440 root:wheel` + `!include` fallback
  - `security.nix` — neovim, firewall, polkit/rtkit
- `storage/`
  - `btrfs.nix`
  - `impermanence.nix` — filesystem-agnostic `/persist`, root-only
  - `impermanence-home.nix` — filesystem-agnostic ephemeral `/home` allowlist, host-imported; works on ext4+tmpfs too
  - `impermanence-btrfs.nix` — btrfs-only initrd rollback: always `/root`, plus `/home` when impermanence-home is imported. Ext4 hosts use impermanence (plus impermanence-home) with a tmpfs `/`. Guide: `system/storage/README.md`
- `boot/`
  - `secureboot.nix` — Lanzaboote, requires impermanence
  - `zswap.nix`
- `types/` — see below

#### System types

A host imports one NixOS type (desktop/server), one Home Manager type (linux-gui/linux-core), and the features it needs.

| Type | Class | Collects |
|---|---|---|
| `core.nix` | nixos | Universal base shared by both system types: nix + direnv + system + locale + ssh + secrets + security + packages |
| `desktop.nix` | nixos | core + desktop-services + home-manager. Compositors (niri/hyprland) and greetd are **not** collected — hosts import nixos.greetd + nixos.niri / nixos.hyprland explicitly |
| `server.nix` | nixos | core only — no desktop, no HM |
| `linux-core.nix` | homeManager | Headless HM: user-ize + shell + cli + dev + terminal + nvim |
| `linux-gui.nix` | homeManager | Full GUI HM: linux-core + linux-desktop + linux-utils + apps + zen-browser + noctalia + notes. Compositors (hm.niri / hm.hyprland) are **not** collected — hosts import them explicitly |
| `desktop-full.nix` | nixos | The uncontroversial desktop core: desktop + user-ize + btrfs + impermanence + impermanence-btrfs + secureboot + zswap + p2p + fhs, plus the shared Syncthing peer. Hosts then list only their deltas (greetd, compositors, docker/podman, vm-qemu, gaming, zerotier); plain `desktop` remains the minimal base |

### `services/` — system daemons

Aspects under `services.*` and `virtualisation.*`, plus firewall rules:

- `ssh.nix` — key-only auth, AllowUsers
- `greetd.nix` — login manager
- `desktop-services.nix` — PipeWire, fonts, bluetooth
- `containers/` — docker.nix (rootless Docker), podman.nix (Podman + HM Distrobox)
- `zerotier.nix` — needs `features.p2p.zerotier.networkId`
- `p2p/` — a **feature closure**: nixos.p2p (Syncthing/NetBird/LocalSend) + homeManager.p2p (tray) in one dir

### `programs/` — user-facing apps

Aspects under `programs.*`, HM `programs.*`, and app bundles. Where a feature spans both classes, both aspects live in one dir (a feature closure): desktop/hyprland/ (nixos.hyprland + homeManager.hyprland) and desktop/niri/ (nixos.niri + homeManager.niri).

- `desktop/` — hyprland/, niri/, noctalia.nix, apps.nix, zen-browser.nix (Zen), notes.nix (Obsidian), linux-desktop.nix (XDG/Nemo/GTK)
- `shell/` — shell.nix (+ bat for MANPAGER), cli.nix (+ wget/tmux), terminal.nix (kitty), linux-utils.nix
- `dev/` — dev.nix (git/lazygit/npm), nvim.nix, vscode.nix, dotnet.nix (SDK + HM extensions), java.nix
- `media/` — recording.nix (OBS)
- `gaming.nix` — nixos.gaming (Steam/Gamescope/Gamemode) + homeManager.gaming (MangoHud/GOverlay)
- `virtualisation/` — vm-qemu (system), vm-bottles / vm-dosbox (HM-only)
- `compat/fhs.nix` — nixos.fhs (nix-ld) + homeManager.fhs (nix-alien)

### `users/` — the primary user

A reusable Multi-Context feature: nixos.user-ize owns the account, homeManager.user-ize re-exports home-base. User identity comes from the username/vars specialArgs (`flake.lib.vars`).

### `hosts/` — composition roots

See [hosts/README.md](hosts/README.md). Each host's `configuration.nix` composes nixos.desktop-full (or minimal nixos.desktop / nixos.server) + feature deltas + relative ./_*.nix pieces; `home.nix` composes linux-gui / linux-core + features; `flake-parts.nix` instantiates via mkNixosHost (or mkNixosServerHost / mkDarwinHost).

## Adding a Module

Create a `.nix` file declaring one `flake.modules.<class>.<name>` piece — `import-tree` picks it up automatically. Rules of thumb:

- Extend a collector (core/desktop/server, linux-core/linux-gui, desktop-full) only for universal core that every host needs. Features are host-imported directly, never collected.
- With few, similar hosts this duplicates feature delta lists across `hosts/<name>/configuration.nix`. Prefer that copy-paste over a second tier of feature collectors until 3+ hosts share a set.
- If a feature spans NixOS + Home Manager, put BOTH aspects in one domain dir (e.g. services/p2p/default.nix, programs/desktop/niri/default.nix).

Aspect naming: the feature name is shared across classes — nixos.niri + homeManager.niri is the niri feature, nixos.p2p + homeManager.p2p is the p2p feature.

## Adding a Desktop Host

Hosts compose nixos.desktop-full (or minimal nixos.desktop) + feature modules in their own `modules/hosts/<name>/configuration.nix` (see [modules/hosts/README.md](hosts/README.md)):

```nix
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  hm = inputs.self.modules.homeManager;
  vars = inputs.self.lib.vars;
in
{
  # Overlays/hostname/stateVersion come from `mkNixosHost` (`modules/nix/lib.nix`).
  flake.modules.nixos.<name> = {
    imports = [
      inputs.disko.nixosModules.default
      nixos.desktop-full # core: desktop + user-ize + btrfs + impermanence + impermanence-btrfs + secureboot + zswap + p2p + fhs
      nixos.greetd # login manager (explicit per host, needs a compositor)
      nixos.niri # Compositor (explicit per host)
      nixos.hyprland # Compositor (explicit per host)
      # ...other feature deltas + host-local `./_*.nix` pieces + external modules...
    ];

    home-manager.users.${vars.username} = hm.<name>;
  };
}
```

## Adding a Server Host

Compose `nixos.server` instead, and instantiate with `mkNixosServerHost` in the host's `flake-parts.nix` (no home-manager). Overlays/hostname/stateVersion come from the factory, same as desktop:

```nix
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.<name> = {
    imports = [
      inputs.disko.nixosModules.default
      nixos.server
      nixos.user-ize
      ./_hardware-configuration.nix
      # ./_services.nix  # optional (host-specific system packages stay
      # inlined in _host-settings.nix unless large enough for their own file)
    ];
  };
}
```

## Using as an External Module

The `nixosModules.default` output (overlays only — minimal, not the opinionated `desktop` type) can be consumed by other flakes:

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
        inherit (nix-config.lib.vars) username;
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

Note: external use requires passing this repo's specialArgs — inputs, username, vars, flakeRoot (see `flake.lib.specialArgs` and the `mkNixosHost` factory in `modules/nix/lib.nix`). The example above is minimal and omits most inputs (disko, home-manager, agenix, etc.); prefer the factory or pass through all inputs. Disko and the HM user binding stay explicit per host (`mkNixosHost` injects overlays/hostname/stateVersion); external use must import `inputs.disko.nixosModules.default` if needed.

## Features

Optional functionality lives in `services/` + `programs/` as plain composable modules — **importing one is enabling it**. Desktop hosts start from nixos.desktop-full (the core above) and list only their deltas:

```nix
imports = [
  inputs.disko.nixosModules.default # explicit per host (not hidden in the factory)
  nixos.desktop-full # desktop + user-ize + btrfs + impermanence + impermanence-btrfs + secureboot + zswap + p2p + fhs
  # nixos.impermanence-home # optional fs-agnostic ephemeral `/home` (padrick experiment; toggle guide in system/storage/README)
  nixos.greetd # login manager (explicit per host, needs a compositor)
  nixos.niri # Niri compositor (explicit per host)
  nixos.hyprland # Hyprland compositor (explicit per host)
  nixos.vm-qemu # QEMU/KVM, virt-manager, SPICE (+ `homeManager.vm-qemu`: viewer clients)
  nixos.gaming # Steam, Gamescope, Gamemode (+ `homeManager.gaming`: MangoHud/GOverlay)
  nixos.zerotier # ZeroTier VPN (needs networkId, see below)
  nixos.docker # Docker rootless (`enable = false` required, runs as user service)
  nixos.podman # Podman daemon/registries (+ `homeManager.podman`: Distrobox CLI)
  nixos.fhs # FHS env via nix-ld (+ `homeManager.fhs`: nix-alien CLI)
];
```

Home-side pieces (vscode, recording, p2p, podman, fhs, vm-qemu, vm-bottles, vm-dosbox, gaming) live alongside their domain siblings under `programs/` + `services/` and are composed in each host's `home.nix` the same way as the system-side ones.

### P2P + ZeroTier

The `p2p` feature configures Syncthing, NetBird (auto-login via an agenix setup key), and LocalSend, with firewall ports opened (the HM tray lives in the same `services/p2p/` dir). ZeroTier lives in its own module — import it and set the host-specific network ID:

```nix
imports = [ nixos.zerotier ];
features.p2p.zerotier.networkId = "88c5b1f339f6593b";
```

### Adding a New Feature

Create `modules/services/<name>.nix` (daemon) or `modules/programs/<group>/<name>.nix` (app) declaring `flake.modules.nixos.<name>` — and `flake.modules.homeManager.<name>` in the SAME file/dir if it spans both (feature closure) — then import it in the hosts that need it. No flags, no collectors:

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

Prefer plain assignment in the host collector. Use `mkDefault` for shared-type values, and `mkForce` only to beat another default:

```nix
{ lib, ... }:

{
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;
  networking.hostName = lib.mkDefault "my-host";
}
```

nixos.p2p (in desktop-full) force-opens the Syncthing + NetBird + LocalSend firewall ports with no per-service toggle by design. A host that wants the daemons without the open ports (or without one daemon) uses the same `mkForce` escape, e.g. `services.syncthing.openDefaultPorts = lib.mkForce false;`.

`networking.firewall` interface-scoped rules (`interfaces."zt*".allowedUDPPorts`) are the narrow alternative to global `allowed*Ports`.
