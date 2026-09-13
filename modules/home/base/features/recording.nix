# Conditional Aspect: OBS Studio from osConfig.features.recording
# Dendritic module: flake.modules.homeManager.home-features-recording
{
  flake.modules.homeManager.home-features-recording =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:

    let
      enabled = lib.attrByPath [ "features" "recording" "enable" ] false osConfig;
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
    };
}
