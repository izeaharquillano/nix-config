{
  flake.modules.homeManager.home-base =
    {
      pkgs,
      username,
      ...
    }:

    {
      home = {
        stateVersion = "26.05";
        inherit username;
        homeDirectory =
          if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
      };
    };
}
