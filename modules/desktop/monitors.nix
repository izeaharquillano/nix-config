{ lib, ... }:

{
  options.host.monitors = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Output name (e.g. eDP-1, DP-1, HDMI-A-1)";
        };
        mode = lib.mkOption {
          type = lib.types.str;
          description = "Resolution and refresh rate (e.g. 1920x1080@60)";
        };
        scale = lib.mkOption {
          type = lib.types.str;
          default = "1";
          description = "Display scale factor";
        };
        position = lib.mkOption {
          type = lib.types.str;
          default = "auto";
          description = "Position (auto, or x=1920 y=0 for niri, 0x0 for hyprland)";
        };
        transform = lib.mkOption {
          type = lib.types.str;
          default = "normal";
          description = "Output transform (normal, 90, 180, 270, flipped, etc.)";
        };
      };
    });
    default = [];
    description = "List of monitor configurations for window managers";
  };


}
