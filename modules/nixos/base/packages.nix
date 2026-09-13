# Simple Aspect: base system packages (wget, tmux)
# Dendritic module: flake.modules.nixos.base-packages
{
  flake.modules.nixos.base-packages =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        wget
        tmux
      ];
    };
}
