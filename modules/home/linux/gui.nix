# Full GUI home; hosts add `home-features-*` as needed.
# Dendritic module: flake.modules.homeManager.home-linux-gui
{ inputs, ... }:
{
  flake.modules.homeManager.home-linux-gui = {
    imports = with inputs.self.modules.homeManager; [
      user-ize
      home-core-shell
      home-core-cli
      home-core-dev
      home-core-terminal
      home-core-nvim
      home-core-notes
      home-linux-desktop
      home-linux-utils
      home-gui-apps
      home-gui-web
      home-gui-hyprland
      home-gui-niri
      home-gui-noctalia
    ];
  };
}
