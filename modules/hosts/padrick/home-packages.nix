# Collector Aspect: padrick home packages (btop)
# Dendritic module: flake.modules.homeManager.padrick-home-packages
{
  flake.modules.homeManager.padrick-home-packages =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        btop
      ];
    };
}
