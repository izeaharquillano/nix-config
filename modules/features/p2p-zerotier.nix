# Simple Aspect: ZeroTier networking.
# Import this module = enabled (pure dendritic: composition decides).
# The network ID is host-specific, so it stays a plain value option
# (no enable flag) set by the importing host.
# Dendritic module: flake.modules.nixos.p2p-zerotier
{
  flake.modules.nixos.p2p-zerotier =
    { lib, config, ... }:

    {
      options.features.p2p.zerotier.networkId = lib.mkOption {
        type = lib.types.str;
        example = "8056c2e21c123456";
        description = "ZeroTier network ID to join on startup";
      };

      config = {
        networking.firewall.allowedUDPPorts = [ 9993 ];
        services.zerotierone = {
          enable = true;
          joinNetworks = [ config.features.p2p.zerotier.networkId ];
        };
      };
    };
}
