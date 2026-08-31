{
  config,
  mylib,
  pkgs,
  username,
  ...
}:

{
  imports = mylib.scanPaths ./.;

  home.stateVersion = "26.05";
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${config.home.username}"
    else
      "/home/${config.home.username}";
}
