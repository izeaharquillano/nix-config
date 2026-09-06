{ pkgs, ... }:

{
  boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];
  boot.initrd.systemd.enable = true;

  boot.initrd.luks.devices."luks-b3de44df-5f22-42ec-bb0b-87147a44830c".allowDiscards = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4*1024;
  }];
}
