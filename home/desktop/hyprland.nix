{ osConfig, lib, ... }:

let
  monitors = osConfig.host.monitors or [];

  renderMonitor = m:
    ''
      hl.monitor({
          output   = "${m.name}",
          mode     = "${m.mode}",
          position = "${m.position}",
          scale    = "${m.scale}",
      })
    '';

  monitorsFile = lib.concatStringsSep "\n\n" (map renderMonitor monitors);
in
{
  xdg.configFile."hypr" = {
    source = ../../config/hypr;
    recursive = true;
  };

  xdg.configFile."hypr/monitors.lua".text = monitorsFile;
}
