{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
    flavors = {
      gruvbox-material = pkgs.gruvbox-material-yazi;
    };
    theme.flavor = {
      dark = "gruvbox-material";
      light = "gruvbox-material";
    };
  };
}
