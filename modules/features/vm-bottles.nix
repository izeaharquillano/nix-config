# Simple Aspect: Bottles Wine runner.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.vm-bottles
{
  flake.modules.nixos.vm-bottles =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [ (bottles.override { removeWarningPopup = true; }) ];
    };
}
