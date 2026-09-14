# Bottles Wine runner.
{
  flake.modules.nixos.vm-bottles =
    { pkgs, ... }:

    {
      environment.systemPackages = [ (pkgs.bottles.override { removeWarningPopup = true; }) ];
    };
}
