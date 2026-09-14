# jobert NVIDIA + kernel params.
{
  flake.modules.nixos.jobert-host-settings =
    {
      config,
      pkgs,
      ...
    }:
    {

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
        graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = [
            pkgs.nvidia-vaapi-driver
          ];
        };

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
    };
}
