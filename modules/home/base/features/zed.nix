# Simple Aspect: Zed editor.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.homeManager.home-features-zed
{
  flake.modules.homeManager.home-features-zed = {
    programs.zed-editor = {
      enable = true;
    };
  };
}
