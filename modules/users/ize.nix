# Multi-Context Aspect: the primary user as a reusable feature.
# The NixOS half owns the user account (moved out of `nixos/base/system.nix`
# so identity lives in exactly one place); the homeManager half re-exports
# `home-base`, giving hosts a single `user-ize` entry point per context.
# Identity values come from the Constants Aspect (`flake.lib.vars`).
# Dendritic modules: flake.modules.nixos.user-ize, flake.modules.homeManager.user-ize
{ inputs, ... }:
let
  vars = inputs.self.lib.vars;
in
{
  flake.modules.nixos.user-ize =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      users.users.${config.mySystem.username} = {
        isNormalUser = true;
        description = vars.userfullname;
        # Set when impermanence is disabled. When enabled, hashedPasswordFile
        # in impermanence.nix takes precedence and this is ignored.
        initialPassword = lib.mkIf (!(config.features.impermanence.enable or false)) "changeme";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };
    };

  flake.modules.homeManager.user-ize = {
    imports = [ inputs.self.modules.homeManager.home-base ];
  };
}
