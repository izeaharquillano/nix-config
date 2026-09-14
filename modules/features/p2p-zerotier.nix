# ZeroTier networking (`networkId` set per host).
{
  flake.modules.nixos.p2p-zerotier =
    { lib, config, ... }:

    {
      options.features.p2p.zerotier.networkId = lib.mkOption {
        type = lib.types.nullOr (lib.types.strMatching "[0-9a-f]{16}");
        default = null;
        example = "8056c2e21c123456";
        description = "ZeroTier network ID to join on startup (16 hex chars). Required when importing this module.";
      };

      config = {
        assertions = [
          {
            assertion = config.features.p2p.zerotier.networkId != null;
            message = "features.p2p.zerotier.networkId must be set when importing nixos.p2p-zerotier (e.g. in modules/hosts/<name>/configuration.nix).";
          }
        ];

        networking.firewall.allowedUDPPorts = [ 9993 ];
        services.zerotierone = {
          enable = true;
          # Assertion above guarantees non-null; no mkIf needed.
          joinNetworks = [
            config.features.p2p.zerotier.networkId
          ];
        };
      };
    };
}
