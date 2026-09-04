# Hosts

Each subdirectory represents a machine. NixOS hosts live under `nixos/`, macOS hosts under `darwin/`.

## Current Hosts

| Host | Platform | Type | Hardware | Purpose |
|---|---|---|---|---|
| `padrick` | NixOS | Laptop | AMD, BTRFS, Wayland | Daily use |
| `jobert` | NixOS | Gaming Laptop | AMD + NVIDIA, BTRFS, Wayland | Work/gaming |

### padrick: Daily Use ThinkPad

```nix
features = {
  btrfs.enable = true;
  secureboot.enable = true;
  zswap.enable = true;
  p2p.enable = true;
  docker.enable = true;
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
  docker.enable = true;
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
