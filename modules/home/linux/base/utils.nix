# Simple Aspect: output-scale wrapper + Wayland utils
# Dendritic module: flake.modules.homeManager.home-linux-utils
{
  flake.modules.homeManager.home-linux-utils =
    { pkgs, flakeRoot, ... }:

    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "output-scale";
          # Shell deps; compositor CLIs (`niri`, `hyprctl`, `noctalia`) come
          # from the running system PATH (programs.niri/hyprland/noctalia).
          runtimeInputs = [
            pkgs.jq
            pkgs.gawk
            pkgs.gnugrep
            pkgs.coreutils
            pkgs.findutils
          ];
          text = builtins.readFile (flakeRoot + /scripts/output-scale);
        })
      ]
      ++ [
        pkgs.p7zip
        pkgs.ncdu
        pkgs.xdg-user-dirs
        # No `waybar` (noctalia is the bar); no `efibootmgr` (in base-packages).
        pkgs.wl-clipboard
        pkgs.brightnessctl
        pkgs.xwayland-satellite
      ];
    };
}
