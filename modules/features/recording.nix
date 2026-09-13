# Conditional Aspect: recording option declaration (HM implements)
# Dendritic module: flake.modules.nixos.recording
{
  flake.modules.nixos.recording =
    { lib, ... }:

    {
      options.features.recording = {
        enable = lib.mkEnableOption "Recording and Related Software (OBS, etc.)";
      };
    };
}
