# Hosts

Each subdirectory is a machine (`padrick/`, `jobert/`; future macOS hosts live under `darwin/`). Each host folder is a dendritic composition root: per-aspect files declare `flake.modules.nixos.<name>-*` pieces, `configuration.nix` composes them into `flake.modules.nixos.<name>`, `home.nix` composes `flake.modules.homeManager.<name>` (desktop/headless HM; servers have no `home.nix`), and `flake-parts.nix` instantiates `nixosConfigurations.<name>` via `mkNixosHost` (or `mkNixosServerHost` / `mkDarwinHost`; see below).

## Current Hosts

| Host | Platform | Type | Hardware | Purpose |
|---|---|---|---|---|
| `padrick` | NixOS | Laptop | AMD, LUKS+BTRFS, Wayland | Daily use |
| `jobert` | NixOS | Gaming Laptop | AMD + NVIDIA, LUKS+BTRFS, Wayland | Work/gaming |

### Disk Encryption (LUKS) & Impermanence

All NixOS hosts use LUKS2 full-disk encryption with btrfs and [impermanence](https://github.com/nix-community/impermanence) (ephemeral root, persistent `/persist` subvolume). Both hosts use [disko](https://github.com/nix-community/disko) for declarative disk management.

| Host | Disk Layout | Notes |
|------|-------------|-------|
| `padrick` | disko | Dual-boot with Windows on same disk |
| `jobert` | disko | NixOS-only disk |

**LUKS settings:** LUKS2, AES-XTS-Plain64, SHA-512, Argon2id, TRIM enabled.

**Impermanence:** Root btrfs subvolume is wiped on every boot via a systemd service in initrd. `/home`, `/nix`, and `/persist` are separate persistent subvolumes. System state (`/var/lib/nixos`, `/etc/machine-id`, `/etc/ssh`, NetworkManager, Bluetooth) is persisted via impermanence bind mounts.

**Swap:** zswap handles compressed swap in RAM. A swapfile on btrfs provides overflow. Hibernation is not configured.

**Disko config files:** `modules/hosts/<name>/disko.nix`

### padrick: Daily Use ThinkPad

Imports `btrfs`, `impermanence`, `secureboot`, `zswap`, `p2p`, `containers`, `fhs`, `vm-qemu`, `vm-bottles`, `vm-dosbox` (+ HM: `vscode`, `p2p`).

### jobert: Gaming & Virtualization

Padrick's set, plus `zerotier` (with `features.p2p.zerotier.networkId`), `gaming` (+ HM: `recording`). See each host's `configuration.nix` / `home.nix` for the exact composition.

The gaming module configures Steam (with remote play + dedicated server firewall rules), Proton GE, Gamescope, Gamemode, MangoHud, and GOverlay. NVIDIA-specific hardware config is in `modules/hosts/jobert/host-settings.nix` (open driver, VA-API, Wayland env vars, 32-bit OpenGL).

## Adding a New Desktop Host

### 1. Create the host directory

```bash
mkdir -p modules/hosts/<name>
mkdir -p modules/hosts/<name>/config
```

### 2. Generate hardware config

```bash
sudo nixos-generate-config --show-hardware-config > modules/hosts/<name>/hardware-configuration.nix
```

### 3. Choose your disk approach

**Option A: NixOS-only disk**

```bash
cp modules/hosts/jobert/disko.nix modules/hosts/<name>/disko.nix
# Edit: update device = "/dev/disk/by-id/..." and swapSize (default "8G")
```

**Option B: Dual-boot with Windows on same disk**

```bash
cp modules/hosts/padrick/disko.nix modules/hosts/<name>/disko.nix
# Edit: update device = "/dev/disk/by-id/..."
# The disko config already reserves space for Windows (MS reserved + data partition)
```

For both options, wrap the disko layout as a dendritic piece of this host
(`flake.modules.nixos.<name>-disko`) via the `mkDiskoBtrfs` factory. Every
host file follows the same shape — a thin `flake.modules.*` declaration
around the plain module body, which `import-tree` picks up automatically
(no aggregator files):

```nix
# Dendritic module: flake.modules.nixos.<name>-disko
{ inputs, ... }:
{
  flake.modules.nixos.<name>-disko = inputs.self.lib.mkDiskoBtrfs {
    diskName = "nixos-<name>";
    device = "/dev/disk/by-id/<actual-disk-id>";
    # withWindows = true; windowsSize = "122070M"; # dual-boot only
    # swapSize = "8G";
  };
}
```

Remove `fileSystems` and `swapDevices` from the generated hardware config — disko provides them.

### 4. Create `modules/hosts/<name>/configuration.nix`

The composition root. It pulls together the `desktop` system type,
the reusable `user-ize` feature, this host's `*-disko`, `*-hardware`,
`*-services`, `*-host-settings` pieces (host-specific packages stay inlined
in `home.nix` / `host-settings.nix`; only split out a `packages.nix` if the
list grows large), external modules,
and exactly the feature modules this host needs (importing one IS
enabling it) — all referenced via `inputs.self.modules.nixos`
(never relative `../../../`):

```nix
# Dendritic composition root: flake.modules.nixos.<name>
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.<name> = {
    imports = [
      nixos.desktop
      nixos.user-ize
      nixos.btrfs
      nixos.impermanence
      nixos.secureboot
      nixos.zswap
      nixos.p2p
      # nixos.zerotier  # + features.p2p.zerotier.networkId below
      # nixos.gaming
      nixos.<name>-disko
      nixos.<name>-hardware
      nixos.<name>-services
      nixos.<name>-host-settings
      # inputs.nixos-hardware.nixosModules.<your-profile>
      # Note: disko + hostname come from the `mkNixosHost` factory; do not
      # import `inputs.disko.nixosModules.default` or set `networking.hostName` here.
    ];

    system.stateVersion = "26.05";
  };
}
```

> **Password setup:** With `impermanence` imported, create `/persist/secrets/hashed-password` during installation (see Step 7 in the reinstall guide). Without impermanence the fallback `initialPassword` (`changeme` in `users/ize.nix`) applies — change it after first boot with `passwd`.

### 5. Create host-specific pieces

Each file declares one `flake.modules.nixos.<name>-*` Collector piece.
`modules/hosts/<name>/host-settings.nix`:

```nix
# Dendritic module: flake.modules.nixos.<name>-host-settings
{
  flake.modules.nixos.<name>-host-settings =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
}
```

`modules/hosts/<name>/services.nix` — for laptops:

```nix
# Dendritic module: flake.modules.nixos.<name>-services
{
  flake.modules.nixos.<name>-services =
    { pkgs, lib, ... }:
    {
      services.resolved.enable = true;
      services.power-profiles-daemon.enable = false;
      services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        };
      };
      services.upower = {
        enable = true;
        percentageLow = 20;
        percentageCritical = 5;
        percentageAction = 2;
        criticalPowerAction = "PowerOff";
      };
    };
}

Host-specific packages are inlined, not separate modules: Home Manager
packages go in `home.packages` in `home.nix` (above); the rare
host-specific system package goes in `environment.systemPackages` in
`host-settings.nix`. Only split out a `packages.nix` collector if the list
grows large enough to deserve its own file.

### 6. Create host-specific config files (Wayland)

`modules/hosts/<name>/config/niri-host-settings.kdl`:

```kdl
output "eDP-1" {
    mode "1920x1080@60"
    scale 1.20
    transform "normal"
}
```

`modules/hosts/<name>/config/hypr-host-settings.lua`:

```lua
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.20",
})
```

Optionally, create `noctalia-host-settings.toml` for Noctalia lockscreen widgets.

### 7. Add Home Manager config

`modules/hosts/<name>/home.nix` (`flake.modules.homeManager.<name>`).
Niri/Noctalia HM modules come via the `linux-gui` collectors, so hosts
only list the GUI type + features, with host-specific packages inlined
(no separate `*-home-packages` module):

```nix
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.<name> =
    { pkgs, ... }:
    {
      imports = [
        hm.linux-gui
        hm.vscode
        hm.p2p
      ];

      home.packages = with pkgs; [
        # host-specific packages
      ];

      xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
      xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
      xdg.configFile."noctalia/host-settings.toml".source = ./config/noctalia-host-settings.toml;
    };
  };
}
```

### 8. Instantiate via `modules/hosts/<name>/flake-parts.nix`

```nix
# Instantiates <name> via the Factory Aspect (`mkNixosHost`).
{ inputs, ... }:
{
  flake.nixosConfigurations.<name> = inputs.self.lib.mkNixosHost "<name>" "x86_64-linux";
}
```

### 9. Secure Boot (first boot, not install time)

No action needed before install: `nixos.secureboot` sets
`boot.lanzaboote.autoGenerateKeys.enable`, so `nixos-install` succeeds with
an empty `/var/lib/sbctl` (unsigned artifacts allowed) and keys are created
automatically on first boot by `generate-sb-keys.service`. Keys persist via
impermanence (`/persist/var/lib/sbctl`).

After first boot, sign then enroll once (firmware in Setup Mode):

```bash
sbctl status
sudo nixos-rebuild boot --flake .#<name>
sudo sbctl verify
sudo sbctl enroll-keys --microsoft
sbctl status
```

To **skip re-enrollment on reinstall**, back up `/var/lib/sbctl` before
wiping and restore it after `disko --mode destroy,format,mount` (see
Reinstall Step 5b below). Restored keys sign the install immediately and
the firmware keeps trusting them.

### 10. First deploy + secrets setup

Follow the two-pass workflow in [Adding a New Host to Secrets](../../README.md#adding-a-new-host-to-secrets): deploy once (generates host keys), `ssh-keyscan`, add the key + `just secrets-rekey` from an existing authorized host, deploy again.

## Adding a New Server Host

### 1. Create the host directory

```bash
mkdir -p modules/hosts/<name>
```

### 2. Generate hardware config

```bash
sudo nixos-generate-config --show-hardware-config > modules/hosts/<name>/hardware-configuration.nix
```

### 3. Create `modules/hosts/<name>/configuration.nix`

```nix
# Dendritic composition root: flake.modules.nixos.<name>
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.<name> = {
    imports = [
      nixos.server
      nixos.user-ize
      nixos.<name>-hardware
      # nixos.<name>-services  # optional (host-specific system packages stay
      # inlined in host-settings.nix unless large enough for their own file)
    ];

    # Hostname comes from the `mkNixosServerHost` factory (`mkDefault`);
    # override here with `mkForce` only if needed without the factory.

    system.stateVersion = "26.05";
  };
}
```

### 4. Create `modules/hosts/<name>/flake-parts.nix`

```nix
{ inputs, ... }:
{
  flake.nixosConfigurations.<name> = inputs.self.lib.mkNixosServerHost "<name>" "x86_64-linux";
}
```

No home-manager is included for servers. If you want headless HM tools, define a `flake.modules.homeManager.<name>` importing `linux-core` and extend the server factory with a home-manager block.

> **Note:** Server hosts typically skip desktop/GUI features and impermanence. The fallback `initialPassword` applies — change it after first boot with `passwd`.

## Adding a New macOS Host

### 1. Create the host directory

```bash
mkdir -p modules/hosts/darwin/<name>
```

### 2. Create `modules/hosts/darwin/<name>/configuration.nix`

```nix
# Dendritic module: flake.modules.darwin.<name>
{ inputs, ... }:
let
  darwin = inputs.self.modules.darwin;
in
{
  flake.modules.darwin.<name> = {
    imports = [
      darwin.nix
      darwin.direnv
      darwin.home-manager
    ];
    networking.hostName = "<name>";
    system.stateVersion = 5;
  };
}
```

### 3. Create Home Manager entry point

`modules/hosts/darwin/<name>/home.nix`:

```nix
# Dendritic module: flake.modules.homeManager.<name>
{ inputs, ... }:
{
  flake.modules.homeManager.<name> = {
    imports = [ inputs.self.modules.homeManager.user-ize ];
    # darwin home modules...
  };
}
```

### 4. Create `modules/hosts/darwin/<name>/flake-parts.nix`

```nix
{ inputs, ... }:
{
  flake.darwinConfigurations.<name> = inputs.self.lib.mkDarwinHost "<name>" "aarch64-darwin";
}
```

### 5. First deploy

```bash
darwin-rebuild switch --flake .#<name>
```

## Disabling Services Per Host

Modules collected by the shared system types (`desktop`/`server`, `linux-core`/`linux-gui`) apply to every host using that type; features only apply when a host imports them. (Note: `import-tree` imports files, enabling happens via composition.) To disable on a specific host, use `lib.mkForce` in the host's `configuration.nix`. See [modules/README.md](../README.md#overriding-modules-per-host) for examples.

## BTRFS: Disable COW for Steam (gaming hosts)

```bash
sudo chattr +C ~/.local/share/Steam
```

Must be done before any files are written to the directory. If Steam is already installed, move the folder, create a fresh one, apply the attribute, then move files back.

---

## Reinstalling a NixOS Host from Scratch

### Prerequisites

- A bootable NixOS USB (use the Minimal ISO from https://nixos.org/download/)
- Internet connection
- This config repo cloned to the USB (or accessible via network)

### Step 1: Boot from USB

Boot the NixOS live ISO.

### Step 2: Find your disk

```bash
ls /dev/disk/by-id/  # NVMe: grep nvme; SATA: grep ata; VM: grep virtio
```

### Step 3: Update disko config

```bash
git clone https://github.com/<your-user>/nix-config.git
cd nix-config

# Update the disk ID in the disko config
$EDITOR modules/hosts/<hostname>/disko.nix
# Set: device = "/dev/disk/by-id/<actual-disk-id>";
```

### Step 4: Run disko

This **wipes the entire disk** and sets up LUKS + btrfs + subvolumes.
disko reads the layout from the host's evaluated system config
(`config.disko.devices`, wired via the `<name>-disko` dendritic piece):

```bash
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake .#<hostname>
```

Enter a LUKS passphrase when prompted.

After disko mounts the fresh disk at `/mnt`, place the edited repo where
`nixos-install` expects it:

```bash
sudo mkdir -p /mnt/etc/nixos
sudo cp -a ~/nix-config /mnt/etc/nixos/nix-config  # adjust source if you cloned elsewhere
```

### Step 5: Generate hardware config

```bash
sudo nixos-generate-config --root /mnt --show-hardware-config \
  > /mnt/etc/nixos/nix-config/modules/hosts/<hostname>/hardware-configuration.nix
```

Remove `fileSystems` and `swapDevices` from the generated hardware config — disko provides those.

### Step 5b (optional): preserve Secure Boot keys across reinstall

`disko --mode destroy,format,mount` wipes `/persist`, so keys in
`/var/lib/sbctl` are lost and the firmware enrollment must be redone —
unless you back them up first (from the running system before wiping):

```bash
just secureboot-backup            # saves /var/lib/sbctl to ./sbctl-backup-<hostname>.tar.gz (gitignored)
# or manually: sudo tar -czpf /tmp/sbctl-backup.tar.gz -C /var/lib sbctl
```

Copy the archive off-disk (USB/second machine), then after Step 4 above
(disko has mounted the fresh disk at `/mnt`) restore before installing.
Both paths matter on impermanence hosts: `/mnt/var/lib/sbctl` is what
`nixos-install` signs with, `/mnt/persist/var/lib/sbctl` is what survives
the first reboot:

```bash
just secureboot-restore ./sbctl-backup-<hostname>.tar.gz
# or manually:
# sudo mkdir -p /mnt/var/lib /mnt/persist/var/lib
# sudo tar -xzpf sbctl-backup-<hostname>.tar.gz -C /mnt/var/lib
# sudo mkdir -p /mnt/persist/var/lib && sudo cp -a /mnt/var/lib/sbctl /mnt/persist/var/lib/
```

Skip this step for fresh keys — `nixos-install` works either way thanks to
`autoGenerateKeys` (installs unsigned, generates on first boot, see Step 9).

### Step 6: Install

```bash
cd /mnt/etc/nixos/nix-config
sudo nixos-install --flake .#<hostname>
```

No `sbctl create-keys` / `nixos-enter` dance needed: with
`boot.lanzaboote.autoGenerateKeys.enable`, the install succeeds without
keys and `generate-sb-keys.service` creates them on first boot.

### Step 7: Create the user password file

**If importing `nixos.impermanence` (import = enable):**

Impermanence requires a hashed password file at `/persist/secrets/hashed-password` before first boot. Since `/persist` is already mounted at this point:

```bash
mkdir -p /mnt/persist/secrets
mkpasswd -m SHA-512 > /mnt/persist/secrets/hashed-password
```

**If NOT importing `nixos.impermanence`:**

No action needed — the fallback `initialPassword` is used. **Change it after first boot** with `passwd`.

### Step 8: Reboot

```bash
sudo reboot
```

Remove the USB. On first boot, enter your LUKS passphrase to unlock.

### Step 9: Secure Boot first-boot (only if you did NOT restore keys)

With fresh keys the ESP artifacts from install are still unsigned. Follow the enroll flow in [Secure Boot (first boot)](#9-secure-boot-first-boot-not-install-time): `sbctl status` → `sudo nixos-rebuild boot` (re-sign) → `sudo sbctl verify` → `sudo sbctl enroll-keys --microsoft` in Setup Mode → reboot → enable Secure Boot → `sbctl status`.

If you restored keys in Step 5b, skip the re-sign — just verify:

```bash
sudo sbctl verify && sbctl status
```

### Post-install

Follow [Adding a New Host to Secrets](../../README.md#adding-a-new-host-to-secrets): `ssh-keyscan`, add the key from another authorized host, `just secrets-rekey`, then `sudo nixos-rebuild switch --flake .#<hostname>`.

### padrick: Windows Dual-Boot Install

After NixOS is installed and working on padrick, install Windows alongside it:

1. **Boot the Windows installer** from a USB
2. **Select the "Windows data" partition** (~119 GiB via `windowsSize = "122070M"`, type 0700) as the install target
3. Windows will detect the existing ESP and may create its own recovery partition
4. **Do NOT format the ESP** — NixOS bootloader lives there
5. After Windows install, you should be able to boot either OS from the firmware menu (F12 on ThinkPad) or configure Lanzaboote/systemd-boot to chainload Windows

If Windows creates a duplicate recovery partition, that's harmless — it just uses a bit of extra space. If you want to reclaim it later, you can delete it from Windows Disk Management.

To add a Windows boot entry to systemd-boot (optional, from NixOS):

```bash
sudo bootctl install  # re-register NixOS as primary
# Then add a Windows entry manually or via a NixOS module
```

**Reverting to pure NixOS:** If Windows dual-boot causes issues, remove the `"Microsoft reserved"` and `"Windows data"` partitions from `disko.nix` (`withWindows = false`), then re-run `disko --mode destroy,format,mount` + `nixos-install` (a rebuild alone won't resize existing partitions). The LUKS/btrfs partitions will then fill the disk.
