# padrick amdgpu + kernel params.
{
  flake.modules.nixos.padrick-host-settings =
    { pkgs, ... }:

    {
      # Delayed AMDGPU (no early KMS): early initrd driver spams whitespace
      # on the console during the LUKS passphrase prompt on this ThinkPad.
      hardware.amdgpu.initrd.enable = false;

      boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = [
          pkgs.libva
          pkgs.libva-vdpau-driver
          pkgs.libvdpau-va-gl
        ];
      };
    };
}
