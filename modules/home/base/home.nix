# Simple Aspect: home stateVersion, username, homeDirectory
# Dendritic module: flake.modules.homeManager.home-base
{
  flake.modules.homeManager.home-base =
    {
      config,
      pkgs,
      username,
      ...
    }:

    {
      home.stateVersion = "26.05";
      home.username = username;
      home.homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "/Users/${config.home.username}"
        else
          "/home/${config.home.username}";
    };
}
