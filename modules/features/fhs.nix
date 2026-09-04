{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.features.fhs;
in
{
  options.features.fhs = {
    enable = lib.mkEnableOption "FHS environment and nix-alien for running unpatched binaries";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [
      nix-alien
    ];
  };
}
