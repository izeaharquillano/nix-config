# Example server host configuration.
# Replace this with your actual server host.
#
# To add a new server:
# 1. Copy this directory: cp -r hosts/nixos/server-example hosts/nixos/myserver
# 2. Update networking.hostName in this file
# 3. Generate hardware-configuration.nix: nixos-generate-config --show-hardware-config > hardware-configuration.nix
# 4. Add the host to outputs/default.nix (see mkNixosServerHost)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../../modules/nixos/server
    ./hardware-configuration.nix
  ];

  networking.hostName = "server-example";

  programs.zsh.enable = true;

  system.stateVersion = "26.05";
}
