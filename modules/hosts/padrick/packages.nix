# Collector Aspect: padrick system packages
# Dendritic module: flake.modules.nixos.padrick-packages
{
  flake.modules.nixos.padrick-packages =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        # host-specific packages
      ];
    };
}
