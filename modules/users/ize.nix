# Multi-Context Aspect: the primary user as a reusable feature.
# Identity values come from specialArgs (`username` + `myvars` in
# `modules/dendritic/lib.nix`) — there is no `mySystem.username` option.
# Dendritic modules: flake.modules.nixos.user-ize, flake.modules.homeManager.user-ize
{
  flake.modules.nixos.user-ize =
    {
      pkgs,
      lib,
      username,
      myvars,
      ...
    }:
    {
      users.users.${username} = {
        isNormalUser = true;
        description = myvars.userfullname;
        # Fallback password for hosts without impermanence (overridable).
        # The impermanence module forces this to null and uses
        # /persist/secrets/hashed-password instead.
        initialPassword = lib.mkDefault "changeme";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };
    };

  flake.modules.homeManager.user-ize =
    { inputs, ... }:
    {
      imports = [ inputs.self.modules.homeManager.home-base ];
    };
}
