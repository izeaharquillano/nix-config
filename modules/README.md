# Modules

Dendritic `flake.modules.<class>.<name>` pieces, grouped by **domain**
(following [Doc-Steve's dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts):
`programs/` / `services/` / `system/` / `users/` / `hosts/` / `nix/`).
Every `.nix` file under `modules/` is auto-imported by `import-tree` —
no aggregator files. File paths are documentation only; the aspect name
(`flake.modules.<class>.<name>`) is the glue. Cross-file composition is
explicit via `inputs.self.modules.*`.

## Domain Groups

- **`nix/`** — Flake infra.
  `flake-parts.nix` (module registry), `lib.nix` (vars incl. `stateVersion`,
  minimal `mkNixosHost` / `mkDarwinHost` factories (`mkNixosServerHost` is an
  alias — headless just means no HM user binding in `configuration.nix`),
  `mkDiskoBtrfs`, `sharedOverlays`, shared `specialArgs`, `mkHostConfigFiles`),
  `darwin-fix.nix`, plus per-system wiring:
  `home-manager.nix` (HM settings + `extraSpecialArgs` forwarding; the HM
  user binding lives in each host's `configuration.nix`), `nixpkgs.nix`, `overlays.nix`, `packages.nix`,
  `treefmt.nix`.
- **`system/`** — OS foundation. Always imported via the `desktop`/`server`
  system types in `system/types/` (Inheritance Aspect).
  - `nix.nix` (`nixos.nix` + `darwin.nix` Multi-Context: shared nix settings),
    `direnv.nix`, `locale.nix`, `system.nix` (boot, networking,
    GC, `features.system.kernelPackage` option), `packages.nix`,
    `secrets.nix` (agenix; `0440 root:wheel` + `!include` fallback),
    `security.nix` (neovim, firewall, polkit/rtkit)
  - `storage/` — `btrfs.nix`, `impermanence.nix`
  - `boot/` — `secureboot.nix` (Lanzaboote, requires impermanence),
    `zswap.nix`
  - `types/` — `desktop.nix` (`nix` + `direnv` + `system` + `locale` +
    `ssh` + `secrets` + `security` + `packages` + `greetd` +
    `desktop-services` + `home-manager`; compositors `niri`/`hyprland`
    are NOT collected — hosts import `nixos.niri`/`nixos.hyprland`
    explicitly), `server.nix`
    (core only, no desktop, no HM), `linux-core.nix` (headless HM:
    `user-ize` + `shell` + `cli` + `dev` + `terminal` + `nvim`),
    `linux-gui.nix` (full GUI HM: `linux-core` + `linux-desktop` +
    `linux-utils` + `apps` + `web` + `noctalia` +
    `notes`; compositors `hm.niri`/`hm.hyprland` are NOT collected —
    hosts import them explicitly). Hosts import one NixOS type (`desktop`/`server`) + one HM
    type (`linux-gui`/`linux-core`) + the features they need.
    `desktop-full.nix` collects the uncontroversial desktop core
    (`desktop` + `user-ize` + `btrfs` + `impermanence` + `secureboot` +
    `zswap` + `p2p` + `fhs`, plus the shared Syncthing peer) so hosts only
    list their deltas (compositors, `docker`/`podman`, `vm-qemu`, `gaming`,
    `zerotier`); plain `desktop` remains the minimal base.
- **`services/`** — System daemons (`services.*`, `virtualisation.*`,
  firewall). `ssh.nix` (key-only, `AllowUsers`), `greetd.nix`, `desktop.nix` (PipeWire, fonts,
  bluetooth), `containers/` (`docker.nix`: rootless Docker, `podman.nix`:
  Podman + HM Distrobox), `zerotier.nix`
  (needs `features.p2p.zerotier.networkId`), and `p2p/` as a **feature
  closure**: `nixos.p2p` (Syncthing/NetBird/LocalSend) + `homeManager.p2p`
  (tray) in one dir.
- **`programs/`** — User-facing apps (`programs.*`, HM `programs.*`,
  app bundles). Feature closures where a feature spans both classes:
  `desktop/hyprland/` (`nixos.hyprland` + `homeManager.hyprland`) and
  `desktop/niri/` (`nixos.niri` + `homeManager.niri`) in one dir each.
  - `desktop/` — `hyprland/`, `niri/`, `noctalia.nix`, `apps.nix`,
    `web.nix` (Zen), `notes.nix` (Obsidian), `linux-desktop.nix` (XDG/Nemo/GTK)
  - `shell/` — `shell.nix` (+ `bat` for `MANPAGER`), `cli.nix` (+ `wget`/`tmux`), `terminal.nix` (kitty), `utils.nix` (`linux-utils` aspect)
  - `dev/` — `dev.nix` (git/lazygit/npm), `nvim.nix`, `vscode.nix`, `zed.nix`
  - `media/` — `recording.nix` (OBS)
  - `gaming.nix` (`nixos.gaming`: Steam/Gamescope/Gamemode + `homeManager.gaming`: MangoHud/GOverlay),
    `virtualisation/` (`vm-qemu` system; `vm-bottles`/`vm-dosbox` HM-only),
    `compat/fhs.nix` (`nixos.fhs`: nix-ld + `homeManager.fhs`: nix-alien)
- **`users/`** — The primary user as a reusable Multi-Context feature
  (`nixos.user-ize` owns the account, `homeManager.user-ize` re-exports
  `home-base`). User identity comes from the `username`/`vars` specialArgs
  (`flake.lib.vars`).
- **`hosts/`** — Per-host composition roots (see `hosts/README.md`):
  `configuration.nix` composes `nixos.desktop-full` (or minimal
  `nixos.desktop`/`nixos.server`) + feature deltas + relative `./_*.nix`
  pieces, `home.nix` composes `linux-gui`/`linux-core`
  + features, `flake-parts.nix` instantiates via `mkNixosHost` (or
  `mkNixosServerHost` / `mkDarwinHost`).

To add a module, create a `.nix` file declaring one
`flake.modules.<class>.<name>` piece — `import-tree` picks it up
automatically. Only extend a collector (`desktop`/`server`,
`linux-core`/`linux-gui`, `desktop-full`) for universal core every host
needs; features are host-imported directly, never collected. If a feature spans
NixOS + Home Manager, put BOTH aspects in one domain dir
(e.g. `services/p2p/default.nix`, `programs/desktop/niri/default.nix`).

Aspect naming: the feature name is shared across classes
(`nixos.niri` + `homeManager.niri` = the `niri` feature;
`nixos.p2p` + `homeManager.p2p` = the `p2p` feature).

## Adding a Desktop Host

Hosts compose `nixos.desktop-full` (or minimal `nixos.desktop`) + feature modules in their own `modules/hosts/<name>/configuration.nix` (see `modules/hosts/README.md`):

```nix
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  hm = inputs.self.modules.homeManager;
  vars = inputs.self.lib.vars;
in
{
  flake.modules.nixos.<name> =
    { lib, ... }:
    {
      imports = [
        inputs.disko.nixosModules.default
        nixos.desktop-full # core: desktop + user-ize + btrfs + impermanence + secureboot + zswap + p2p + fhs
        nixos.niri # Compositor (explicit per host)
        nixos.hyprland # Compositor (explicit per host)
        # ...other feature deltas + host-local `./_*.nix` pieces + external modules...
      ];

      nixpkgs.overlays = inputs.self.lib.sharedOverlays;
      networking.hostName = lib.mkDefault "<name>";

      home-manager.users.${vars.username} = hm.<name>;
    };
}
```

## Adding a Server Host

Compose `nixos.server` instead, and instantiate with `mkNixosServerHost` in the host's `flake-parts.nix` (no home-manager). Set hostname/overlays explicitly, same as desktop:

```nix
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.<name> =
    { lib, ... }:
    {
      imports = [
        inputs.disko.nixosModules.default
        nixos.server
        nixos.user-ize
        ./_hardware-configuration.nix
        # ./_services.nix  # optional (host-specific system packages stay
        # inlined in _host-settings.nix unless large enough for their own file)
      ];

      nixpkgs.overlays = inputs.self.lib.sharedOverlays;
      networking.hostName = lib.mkDefault "<name>";

      system.stateVersion = inputs.self.lib.vars.stateVersion;
    };
}
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

Note: external use requires passing this repo's `specialArgs` (`inputs`, `username`, `vars`, `flakeRoot` — see `flake.lib.specialArgs` and the `mkNixosHost` factory in `modules/nix/lib.nix`). The example above is minimal and omits most inputs (disko, home-manager, agenix, etc.); prefer the factory or pass through all inputs. Disko/overlays/hostname are set explicitly in host `configuration.nix` files; external use must import `inputs.disko.nixosModules.default` if needed.

## Features

Optional functionality lives in `services/` + `programs/` as plain composable modules — **importing one is enabling it**. Desktop hosts start from `nixos.desktop-full` (core above) and list only their deltas:

```nix
imports = [
  inputs.disko.nixosModules.default # explicit per host (not hidden in the factory)
  nixos.desktop-full # desktop + user-ize + btrfs + impermanence + secureboot + zswap + p2p + fhs
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

Home-side pieces (`vscode`, `zed`, `recording`, `p2p`, `podman`, `fhs`,
`vm-qemu`, `vm-bottles`, `vm-dosbox`, `gaming`) live alongside their
domain siblings under `programs/` + `services/` and are composed in each
host's `home.nix` the same way (`linux-gui` + `niri` + `hyprland` +
`vscode` + `recording` + `p2p` + ...).

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

`nixos.p2p` (in `desktop-full`) force-opens Syncthing + NetBird + LocalSend
firewall ports with no per-service toggle by design — a host that wants the
daemons without the open ports (or without one daemon) uses the same
`mkForce` escape, e.g. `services.syncthing.openDefaultPorts = lib.mkForce false;`.
`networking.firewall` interface-scoped rules (`interfaces."zt*".allowedUDPPorts`)
are the narrow alternative to global `allowed*Ports`.
