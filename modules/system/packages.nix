# Simple Aspect: base system packages
# Dendritic module: flake.modules.nixos.packages
{
  flake.modules.nixos.packages =
    { pkgs, ... }:

    {
      environment.systemPackages = [
        pkgs.wget
        pkgs.tmux
        # System tool (needs root); was in linux-utils.
        pkgs.efibootmgr
      ];
    };
}
