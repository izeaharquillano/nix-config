# Collector Aspect: jobert home packages
# Dendritic module: flake.modules.homeManager.jobert-home-packages
{
  flake.modules.homeManager.jobert-home-packages =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        btop-cuda
        chromium
        prismlauncher
      ];
    };
}
