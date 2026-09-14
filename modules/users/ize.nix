# Primary user; identity via `username`/`vars` specialArgs.
{
  flake.modules.nixos.user-ize =
    {
      pkgs,
      lib,
      username,
      vars,
      ...
    }:
    {
      users.users.${username} = {
        isNormalUser = true;
        description = vars.userfullname;
        # Fallback password for personal config; impermanence hosts override
        # with `hashedPasswordFile` from /persist (mkForce null below).
        initialPassword = lib.mkDefault "changeme";
        extraGroups = [
          "audio"
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
        linger = true; # keep user services alive at boot.
      };
    };

  flake.modules.homeManager.user-ize =
    { inputs, ... }:
    {
      imports = [ inputs.self.modules.homeManager.home-base ];
    };
}
