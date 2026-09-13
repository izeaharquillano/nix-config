# Collector Aspect: jobert system packages
# Dendritic module: flake.modules.nixos.jobert-packages
{
  flake.modules.nixos.jobert-packages =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
      ];
    };
}
