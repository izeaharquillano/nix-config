{ pkgs, lib, ... }:

{
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/f9727e0a-51c2-431b-9ce7-5135d259bef2";
    }
  ];

  boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
}
