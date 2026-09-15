{
  flake.modules.homeManager.home-base =
    {
      pkgs,
      username,
      vars,
      ...
    }:

    {
      home = {
        # Pinned per HM manual; do NOT bump on update (single source: `vars.stateVersion`).
        inherit (vars) stateVersion;
        inherit username;
        homeDirectory =
          if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
      };
    };
}
