# FHS env (nix-ld) + nix-alien for unpatched binaries.
{
  flake.modules.nixos.fhs =
    { pkgs, ... }:

    {
      programs.nix-ld = {
        enable = true;
        libraries = [
          pkgs.stdenv.cc.cc.lib
          pkgs.glib
          pkgs.zlib
        ];
      };

      environment.systemPackages = [
        pkgs.nix-alien
      ];
    };
}
