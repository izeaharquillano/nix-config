# Simple Aspect: FHS env (nix-ld) + nix-alien for unpatched binaries.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.fhs
{
  flake.modules.nixos.fhs =
    { pkgs, ... }:

    {
      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        nix-alien
      ];
    };
}
