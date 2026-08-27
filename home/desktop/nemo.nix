{ config, pkgs, ... }:

{
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo";
    icon = "nemo";
  };
}
