{ config, pkgs, lib, ... }:

let
  btrfsOpts = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
in
{
  boot.kernelParams = [ "amd_pstate=active" ];

  fileSystems."/".options = btrfsOpts;
  fileSystems."/home".options = [ "subvol=home" ] ++ btrfsOpts;
  fileSystems."/nix".options = [ "subvol=nix" ] ++ btrfsOpts;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };
}
