{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "ehci_pci"
    "xhci_pci_renesas"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/TODO-UPDATE-AFTER-LUKS-FORMAT";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
      "ssd"
      "discard=async"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
      "ssd"
      "discard=async"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
      "ssd"
      "discard=async"
      "nodatacow"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/TODO-UPDATE-AFTER-ESP-FORMAT";
    fsType = "vfat";
    options = [
      "fmask=0177"
      "dmask=0077"
      "noexec"
      "nosuid"
      "nodev"
    ];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
    }
  ];

  boot.initrd.systemd.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
