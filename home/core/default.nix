{ ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./packages.nix
    ./editor.nix
  ];

  home.stateVersion = "26.05";
  home.username = "ize";
  home.homeDirectory = "/home/ize";
}
