{ pkgs, myvars, ... }:

{
  home.packages = with pkgs; [
    gcc
    lazygit
    opencode
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = myvars.userfullname;
        email = myvars.useremail;
      };
    };
  };

  programs.npm.enable = true;
}
