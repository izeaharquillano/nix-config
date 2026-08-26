{ config, pkgs, lib, ... }:

{
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

  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords="RMForcePstate=5"
    options nvidia_drm fbdev=1
  '';

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
