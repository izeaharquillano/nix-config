{ pkgs, ... }:

{
  users.users."ize" = {
    isNormalUser = true;
    description = "ize";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
}
