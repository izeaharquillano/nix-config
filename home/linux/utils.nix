{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "output-scale";
      runtimeInputs = with pkgs; [ jq ];
      text = builtins.readFile ../../scripts/output-scale;
    })
  ] ++ (with pkgs; [
    ncdu
    xdg-user-dirs
    waybar
    wl-clipboard
    brightnessctl
    xwayland-satellite
  ]);
}
