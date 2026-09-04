{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  enabled = lib.attrByPath [ "features" "editors" "enable" ] false osConfig;
in
lib.mkIf enabled {
  programs.obs-studio = {
    enable = true;

    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };
}
