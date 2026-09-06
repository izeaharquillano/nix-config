# Hosts

Each subdirectory represents a machine. NixOS hosts live under `nixos/`, macOS hosts under `darwin/`.

## Current Hosts

| Host | Platform | Type | Hardware | Purpose |
|---|---|---|---|---|
| `padrick` | NixOS | Laptop | AMD, LUKS+BTRFS, Wayland | Daily use |
| `jobert` | NixOS | Gaming Laptop | AMD + NVIDIA, LUKS+BTRFS, Wayland | Work/gaming |

### Disk Encryption (LUKS)

All NixOS hosts use LUKS2 full-disk encryption with btrfs.

| Host | Approach | Disk |
|------|----------|------|
| `padrick` | Manual LUKS setup (dual-boot with Windows on same disk) | NixOS partitions only, Windows preserved |
| `jobert` | [disko](https://github.com/nix-community/disko) (NixOS-only disk) | Full disk wipe via disko |

**Disk layout:**

```
padrick (dual-boot):
  nvme0n1
  ├── p1: Windows recovery
  ├── p2: Windows C: (NTFS)
  ├── p3: Windows data (NTFS)
  ├── p4: ESP (4G, vfat, /boot)
  ├── p5: LUKS2 → btrfs (@root, @home, @nix, @swap)
  └── p6: (reserved)

jobert (disko, NixOS-only):
  nvme0n1
  ├── ESP (4G, vfat, /boot)
  └── LUKS2 → btrfs (@root, @home, @nix, @swap)
```

**LUKS settings:** LUKS2, AES-XTS-Plain64, SHA-512, Argon2id, 5000ms iteration time, TRIM enabled.

**Hibernation:** Enabled via `boot.initrd.systemd.enable = true` (NixOS 26.05 auto-detects swapfile and resume offset via EFI variables). Swapfile size = RAM size (rounded up).

**Disko config files:** `hosts/nixos/<name>/disko.nix` (jobert only)

### padrick: Daily Use ThinkPad

```nix
features = {
  btrfs.enable = true;
  secureboot.enable = true;
  zswap.enable = true;
  p2p.enable = true;
  containers.enable = true;
  vm.enable = true;
  editors.enable = true;
  fhs.enable = true;
};
```

### jobert: Gaming & Virtualization

```nix
features = {
  btrfs.enable = true;
  secureboot.enable = true;
  zswap.enable = true;
  p2p = {
    enable = true;
    zerotier = {
      enable = true;
      networkId = "YOUR_NETWORK_ID";
    };
  };
  vm.enable = true;
  gaming.enable = true;
  containers.enable = true;
  fhs.enable = true;
  recording.enable = true;
};
```

The gaming module configures Steam (with remote play + dedicated server firewall rules), Proton GE, Gamescope, Gamemode, MangoHud, and GOverlay. NVIDIA-specific hardware config is in `hosts/nixos/jobert/host-settings.nix` (open driver, VA-API, Wayland env vars, 32-bit OpenGL).

## Adding a New Desktop Host

### 1. Create the host directory

```bash
mkdir -p hosts/nixos/<name>
mkdir -p home/hosts/nixos/<name>/config
```

### 2. Generate hardware config

```bash
sudo nixos-generate-config --show-hardware-config > hosts/nixos/<name>/hardware-configuration.nix
```

### 3. Create `hosts/nixos/<name>/default.nix`

```nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../../modules/nixos/desktop.nix
    ../../../modules/features
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./host-settings.nix
  ];

  networking.hostName = "<name>";

  features = {
    btrfs.enable = true;
    secureboot.enable = true;
    zswap.enable = true;
    p2p.enable = true;
  };

  system.stateVersion = "26.05";
}
```

### 4. Create `hosts/nixos/<name>/services.nix`

For laptops (power management):

```nix
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
}
```

### 5. Create host-specific config files

`home/hosts/nixos/<name>/config/niri-host-settings.kdl`:

```kdl
output "eDP-1" {
    mode "1920x1080@60"
    scale 1.20
    transform "normal"
}
```

`home/hosts/nixos/<name>/config/hypr-host-settings.lua`:

```lua
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.20",
})
```

Optionally, create `noctalia-host-settings.toml` for Noctalia lockscreen widgets.

### 6. Add Home Manager config

`home/hosts/nixos/<name>/default.nix`:

```nix
{ config, inputs, ... }:

{
  imports = [
    ../../../linux/gui.nix
    ../../../base/features
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
  xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
}
```

### 7. Register in `outputs/default.nix`

```nix
nixosConfigurations.<name> = mkNixosHost "<name>" "x86_64-linux";
```

### 8. Secure Boot (optional, first-time only)

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
sbctl status
```

### 9. First deploy + secrets setup

```bash
sudo nixos-rebuild switch --flake .#<name>
ssh-keyscan <name> 2>/dev/null | grep ssh-ed25519
# Add key to secrets/secrets.nix and rekey (see root README)
sudo nixos-rebuild switch --flake .#<name>
```

## Adding a New Server Host

### 1. Create the host directory

```bash
mkdir -p hosts/nixos/<name>
```

### 2. Generate hardware config

```bash
sudo nixos-generate-config --show-hardware-config > hosts/nixos/<name>/hardware-configuration.nix
```

### 3. Create `hosts/nixos/<name>/default.nix`

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../modules/nixos/server
    ./hardware-configuration.nix
  ];

  networking.hostName = "<name>";

  programs.zsh.enable = true;

  system.stateVersion = "26.05";
}
```

### 4. Register in `outputs/default.nix`

```nix
nixosConfigurations.<name> = mkNixosServerHost "<name>" "x86_64-linux";
```

No home-manager is included for servers. If you want headless HM tools, import `home/linux/core.nix` in a home-manager entry and add a `mkNixosServerHost` variant with HM.

## Adding a New macOS Host

### 1. Create the host directory

```bash
mkdir -p hosts/darwin/<name>
mkdir -p home/hosts/darwin/<name>
```

### 2. Create `hosts/darwin/<name>/default.nix`

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../modules/darwin
  ];

  networking.hostName = "<name>";

  system.stateVersion = 5;
}
```

### 3. Create Home Manager entry point

`home/hosts/darwin/<name>/default.nix`:

```nix
{ config, inputs, ... }:

{
  imports = [
    ../../darwin
    ../../base/home.nix
  ];
}
```

### 4. Register in `outputs/default.nix`

```nix
darwinConfigurations.<name> = mkDarwinHost "<name>" "aarch64-darwin";
```

### 5. First deploy

```bash
darwin-rebuild switch --flake .#<name>
```

## Disabling Services Per Host

Services enabled in shared modules apply to all hosts via `scanPaths`. To disable on a specific host, use `lib.mkForce` in the host's `default.nix`. See [modules/README.md](../modules/README.md#overriding-modules-per-host) for examples.

## BTRFS: Disable COW for Steam

```bash
sudo chattr +C ~/.local/share/steam
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
ls /dev/disk/by-id/ | grep nvme
```

### Step 3: Update disko config

```bash
git clone https://github.com/<your-user>/nix-config.git
cd nix-config

# Update the disk ID in the disko config
$EDITOR hosts/nixos/<hostname>/disko.nix
# Change: device = "/dev/disk/by-id/TODO-YOUR-DISK-ID";
# To:     device = "/dev/disk/by-id/<actual-disk-id>";
#
# Also update swap.swapfile.size to match the host's RAM
```

### Step 4: Run disko

This **wipes the entire disk** and sets up LUKS + btrfs + subvolumes:

```bash
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  ./hosts/nixos/<hostname>/disko.nix
```

Enter a LUKS passphrase when prompted.

### Step 5: Generate hardware config

```bash
sudo nixos-generate-config --root /mnt --show-hardware-config \
  > /mnt/etc/nixos/nix-config/hosts/nixos/<hostname>/hardware-configuration.nix
```

Remove `fileSystems` and `swapDevices` from the generated hardware config — disko provides those.

### Step 6: Install

```bash
cd /mnt/etc/nixos/nix-config
sudo nixos-install --flake .#<hostname>
```

### Step 7: Reboot

```bash
sudo reboot
```

Remove the USB. On first boot, enter your LUKS passphrase to unlock.

### Post-install

```bash
ssh-keyscan <hostname> 2>/dev/null | grep ssh-ed25519
# Add key to secrets/secrets.nix from another authorized host, then rekey
sudo agenix --rekey
sudo nixos-rebuild switch --flake .#<hostname>
```

---

## Adding a New Host

### 1. Create the host directory

```bash
mkdir -p hosts/nixos/<name>
mkdir -p home/hosts/nixos/<name>/config
```

### 2. Choose your disk approach

**Option A: NixOS-only disk (use disko)**

```bash
cp hosts/nixos/jobert/disko.nix hosts/nixos/<name>/disko.nix
# Edit: update device = "/dev/disk/by-id/..." and swap.swapfile.size
```

Then in `hosts/nixos/<name>/default.nix`, add to imports:
```nix
inputs.disko.nixosModules.default
./disko.nix
```

Remove `fileSystems` and `swapDevices` from the generated hardware config — disko provides them.

**Option B: Dual-boot with Windows (manual LUKS)**

Copy `hosts/nixos/padrick/hardware-configuration.nix` as a template. It contains the LUKS, fileSystems, and swapDevices declarations. Follow the dual-boot reinstall steps below to manually set up LUKS from the live ISO.

Do **not** add disko imports to `default.nix` for this approach.

### 3. Create `hosts/nixos/<name>/default.nix`

```nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.default
    ./disko.nix
    ../../../modules/nixos/desktop.nix
    ../../../modules/features
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./host-settings.nix
  ];

  networking.hostName = "<name>";

  features = {
    btrfs.enable = true;
    secureboot.enable = true;
    zswap.enable = true;
    p2p.enable = true;
  };

  system.stateVersion = "26.05";
}
```

### 5. Create host-specific config files

`hosts/nixos/<name>/host-settings.nix`:

```nix
{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
```

`hosts/nixos/<name>/services.nix` — for laptops:

```nix
{ pkgs, lib, ... }:

{
  services.resolved.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
}
```

`hosts/nixos/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # host-specific packages
  ];
}
```

### 6. Add Home Manager config

`home/hosts/nixos/<name>/default.nix`:

```nix
{ config, inputs, ... }:

{
  imports = [
    ../../linux/gui.nix
    ../../base/features
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
}
```

`home/hosts/nixos/<name>/config/niri-host-settings.kdl`:

```kdl
output "eDP-1" {
    mode "1920x1080@60"
    scale 1.20
    transform "normal"
}
```

### 7. Register in `outputs/default.nix`

```nix
nixosConfigurations.<name> = mkNixosHost "<name>" "x86_64-linux";
```

### 8. Secure Boot enrollment (first-time only)

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
sbctl status
```

### 9. Deploy

```bash
# From the NixOS live ISO:
sudo nixos-install --flake .#<name>

# After rebooting into the new system:
sudo nixos-rebuild switch --flake .#<name>
```

### 10. Secrets setup

```bash
ssh-keyscan <name> 2>/dev/null | grep ssh-ed25519
# Add key to secrets/secrets.nix on an existing authorized host
sudo agenix --rekey
sudo nixos-rebuild switch --flake .#<name>
```
