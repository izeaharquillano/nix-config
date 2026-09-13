{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "output-scale";
      runtimeInputs = with pkgs; [ jq ];
      text = builtins.readFile ../../../scripts/output-scale;
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
}
