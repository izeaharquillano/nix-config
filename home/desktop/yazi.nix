{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
    flavors = {
      gruvbox-material = pkgs.fetchFromGitHub {
        owner = "matt-dong-123";
        repo = "gruvbox-material.yazi";
        rev = "main";
        hash = "sha256-mfIdFIe++jRDbTQBcLlpAq91JzmgL2SvqPxkYuCnKdQ=";
      };
    };
    theme.flavor = {
      dark = "gruvbox-material";
      light = "gruvbox-material";
    };
  };
}
