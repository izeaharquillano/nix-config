# FHS env: system nix-ld + per-user nix-alien.
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
    };

  flake.modules.homeManager.fhs =
    { pkgs, ... }:

    {
      home.packages = [
        pkgs.nix-alien
      ];
    };
}
