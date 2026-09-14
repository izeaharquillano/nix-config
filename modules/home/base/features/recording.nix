# Simple Aspect: OBS Studio with CUDA + plugins.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.homeManager.home-features-recording
{
  flake.modules.homeManager.home-features-recording =
    { pkgs, ... }:

    {
      programs.obs-studio = {
        enable = true;

        package = pkgs.obs-studio.override {
          cudaSupport = true;
        };

        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi # optional AMD hardware acceleration
          obs-gstreamer
          obs-vkcapture
        ];
      };
    };
}
