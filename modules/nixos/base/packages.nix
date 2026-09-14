# Simple Aspect: base system packages
# Dendritic module: flake.modules.nixos.base-packages
{
  flake.modules.nixos.base-packages =
    { pkgs, ... }:

    {
      environment.systemPackages = [
        pkgs.wget
        pkgs.tmux
        # System tool (needs root); was in home-linux-utils.
        pkgs.efibootmgr
      ];
    };
}
