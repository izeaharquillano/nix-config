# Multi-Context Aspect: the primary user as a reusable feature.
# Identity from specialArgs (`username`/`myvars`); no `mySystem.username`.
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
        # Fallback password; impermanence uses /persist/secrets/hashed-password.
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
