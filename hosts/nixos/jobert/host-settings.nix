{
  config,
  pkgs,
  lib,
  ...
}:
{

  boot.kernelParams = [
    "amd_pstate=active"
    "amd_pmc.suspend_delay=1"
  ];

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/64be0cf0-e081-46aa-84c8-03d7d602d89b";
      options = [ "discard" ];
    }
  ];

  boot.initrd.kernelModules = [ "nvidia" ];

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
    options nvidia NVreg_EnableS0ixPowerManagement=1
    options nvidia_drm fbdev=1 modeset=1
  '';

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
