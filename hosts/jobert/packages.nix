{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # host-specific packages
  ];

  programs.steam = {
    enable = true;
  };

  programs.gamemode.enable = true;
}
