# Collector Aspect: padrick amdgpu + kernel params
# Dendritic module: flake.modules.nixos.padrick-host-settings
{
  flake.modules.nixos.padrick-host-settings =
    { pkgs, ... }:

    {
      hardware.amdgpu.initrd.enable = false;

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
    };
}
