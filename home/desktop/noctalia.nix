{ ... }:

{
  programs.noctalia = {
    enable = true;
    settings = { };
  };

  xdg.configFile."noctalia/config.toml".source = ../../config/noctalia/config.toml;
}
