# padrick amdgpu + kernel params (`graphics.enable` in desktop-services).
{ pkgs, ... }:

{
  # No early KMS: the initrd driver spams whitespace over the LUKS prompt.
  hardware.amdgpu.initrd.enable = false;

  boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];

  hardware.graphics.extraPackages = [
    pkgs.libva
    pkgs.libva-vdpau-driver
    pkgs.libvdpau-va-gl
  ];
}
