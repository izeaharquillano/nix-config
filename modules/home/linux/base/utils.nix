# Simple Aspect: output-scale wrapper + Wayland utils
# Dendritic module: flake.modules.homeManager.home-linux-utils
{
  flake.modules.homeManager.home-linux-utils =
    { pkgs, flakeRoot, ... }:

    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "output-scale";
          runtimeInputs = with pkgs; [ jq ];
          text = builtins.readFile (flakeRoot + /scripts/output-scale);
        })
      ]
      ++ (with pkgs; [
        p7zip
        efibootmgr
        ncdu
        xdg-user-dirs
        waybar
        wl-clipboard
        brightnessctl
        xwayland-satellite
      ]);
    };
}
