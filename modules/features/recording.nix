{ lib, ... }:

{
  options.features.recording = {
    enable = lib.mkEnableOption "Recording and Related Software (OBS, etc.)";
  };
}
