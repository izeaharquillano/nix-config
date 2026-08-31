{
  config,
  mylib,
  username,
  ...
}:

{
  imports = mylib.scanPaths ./.;

  home.stateVersion = "26.05";
  home.username = username;
  home.homeDirectory = "/home/${config.home.username}";
}
