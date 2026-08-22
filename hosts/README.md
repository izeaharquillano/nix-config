# Hosts

Each subdirectory here represents a NixOS machine. The host's `default.nix` is the entry point that imports shared modules and applies host-specific overrides.

## Current Hosts

| Host | Type | Hardware | Purpose |
|---|---|---|---|
| `padrick` | Laptop | AMD, BTRFS, Wayland | Daily use |

## Adding a New Host

### 1. Create the host directory

```bash
mkdir hosts/<name>
```

### 2. Add hardware configuration

On the target machine, generate it:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Or copy from an existing host and modify.

### 3. Create `hosts/<name>/default.nix`

```nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/core              # Base system config
    ../../modules/desktop           # Desktop environment (skip for servers)
    ../../modules/security.nix      # Git, neovim, nix-ld
    ./hardware-configuration.nix
  ];

  networking.hostName = "<name>";

  # Host-specific overrides
  # e.g. disable laptop services on a desktop:
  # services.tlp.enable = lib.mkForce false;

  system.stateVersion = "26.05";
}
```

### 4. Add Home Manager config (optional)

Create `home/hosts/<name>.nix`:

```nix
{ pkgs, inputs, ... }:

{
  imports = [
    ../../home/core
    ../../home/desktop
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  # Host-specific HM overrides
}
```

### 5. Register in `flake.nix`

Add a new entry in the `outputs` attrset:

```nix
nixosConfigurations.<name> = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hosts/<name>
    lanzaboote.nixosModules.lanzaboote
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ize = import ./home/hosts/<name>.nix;
        extraSpecialArgs = { inherit inputs; };
      };
    }
  ];
};
```

### 6. Deploy

```bash
sudo nixos-rebuild switch --flake .#<name>
```
