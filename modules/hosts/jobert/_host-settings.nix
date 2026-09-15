# jobert NVIDIA + kernel params (`graphics.enable` in desktop-services).
{
  config,
  pkgs,
  ...
}:

{

  # Pinned to 7.2 (== `latest` today): `stable` lags a floating kernel.
  # Bump deliberately.
  features.system.kernelPackage = pkgs.linuxPackages_7_2;

  boot = {
    kernelParams = [
      "amd_pstate=active"
    ];

    initrd.kernelModules = [ "nvidia" ];

    extraModprobeConfig = ''
      options nvidia NVreg_EnableS0ixPowerManagement=1
    '';
  };

  hardware = {
    graphics.extraPackages = [
      pkgs.nvidia-vaapi-driver
    ];

    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      open = true;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
