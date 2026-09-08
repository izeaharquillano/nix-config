{ pkgs, ... }:

{
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
