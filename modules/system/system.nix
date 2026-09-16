# Boot, networking, GC.
{
  flake.modules.nixos.system =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      options.features.system = {
        kernelPackage = lib.mkOption {
          # Kernel sets are attrsets, not derivations.
          type = lib.types.attrs;
          default = pkgs.linuxPackages_latest;
          defaultText = lib.literalExpression "pkgs.linuxPackages_latest";
          example = lib.literalExpression "pkgs.linuxPackages_6_12";
          description = "Linux kernel packages set to use (e.g. pkgs.linuxPackages_latest)";
        };
      };

      config = {
        boot = {
          kernelPackages = config.features.system.kernelPackage;

          loader = {
            # `mkDefault` so lanzaboote can override without `mkForce`.
            efi.canTouchEfiVariables = lib.mkDefault true;
            timeout = lib.mkDefault 10;
            systemd-boot.enable = lib.mkDefault true;
          };
        };

        networking.networkmanager.enable = lib.mkDefault true;
        hardware.enableAllFirmware = lib.mkDefault true;

        # Shorten offline boot wait (upstream `nm-online` default is 30s).
        # Ordering-only `after = network-online.target` consumers (e.g. HM)
        # still get network-first when it's quick, but don't stall offline.
        systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
          lib.mkIf config.networking.networkmanager.enable
            [
              ""
              "${lib.getExe' config.networking.networkmanager.package "nm-online"} -s -q --timeout=10"
            ];

        nix = {
          gc = {
            automatic = true;
            persistent = true;
            dates = [ "weekly" ];
            # 30d keeps rollback generations around (matches `just gc`).
            options = "--delete-older-than 30d";
          };

          optimise = {
            automatic = true;
            dates = [ "weekly" ];
          };
        };
      };
    };
}
