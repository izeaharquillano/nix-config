{ ... }:

{
  xdg.configFile."niri" = {
    source = ../../config/niri;
    recursive = true;
  };
}
