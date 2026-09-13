# Conditional Aspect: nix-ld + nix-alien for unpatched binaries
# Dendritic module: flake.modules.nixos.fhs
{
  flake.modules.nixos.fhs =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      cfg = config.features.fhs;
      mkEnabledOption = desc: lib.mkEnableOption desc // { default = true; };
    in
    {
      options.features.fhs = {
        enable = lib.mkEnableOption "FHS environment and nix-alien";
        nix-ld.enable = mkEnabledOption "Allows running unpatched binaries";
        nix-alien.enable = mkEnabledOption "Same as nix-ld but automated lib fetching";
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [

          (lib.mkIf cfg.nix-ld.enable {
            programs.nix-ld.enable = true;
          })

          (lib.mkIf cfg.nix-alien.enable {
            environment.systemPackages = with pkgs; [
              nix-alien
            ];
          })

        ]
      );
    };
}
