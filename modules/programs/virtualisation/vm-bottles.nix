# Bottles Wine runner (per-user; HM-only feature).
{
  flake.modules.homeManager.vm-bottles =
    { pkgs, ... }:

    {
      home.packages = [ (pkgs.bottles.override { removeWarningPopup = true; }) ];
    };
}
