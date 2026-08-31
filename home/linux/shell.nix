{ config, ... }:

let
  cache = config.xdg.cacheHome;
  c = config.xdg.configHome;
in
{
  home.sessionVariables = {
    LESSHISTFILE = cache + "/less/history";
    LESSKEY = c + "/less/lesskey";
  };
}
