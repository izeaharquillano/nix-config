# Primary user; identity via `username`/`vars` specialArgs.
{
  flake.modules.nixos.user-ize =
    {
      config,
      pkgs,
      lib,
      username,
      vars,
      ...
    }:
    {
      # Login shell must exist wherever the user does (incl. headless servers).
      programs.zsh.enable = true;

      users.users.${username} = {
        isNormalUser = true;
        description = vars.userfullname;
        # `changeme` only where impermanence provides no hash file —
        # change it immediately with `passwd`.
        initialPassword = lib.mkIf (!((config.environment.persistence or { }) ? "/persist")) (
          lib.mkDefault "changeme"
        );
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
