# Conditional Aspect: VSCode/Zed from osConfig.features.editors
# Dendritic module: flake.modules.homeManager.home-features-editors
{
  flake.modules.homeManager.home-features-editors =
    {
      osConfig,
      lib,
      pkgs,
      flakeRoot,
      ...
    }:

    let
      cfg = osConfig.features.editors or { enable = false; };
    in
    lib.mkIf cfg.enable (
      lib.mkMerge [

        (lib.mkIf (cfg.vscode.enable or false) {
          programs.vscode = {
            enable = true;
            package = pkgs.vscode;
            profiles.default.extensions = with pkgs.vscode-extensions; [
              vscodevim.vim
              jdinhlife.gruvbox
              jnoortheen.nix-ide
              ms-dotnettools.csharp
            ];
          };
          xdg.configFile."Code/User/settings.json".source = flakeRoot + /config/vscode/settings.json;
          xdg.configFile."vscode/.vimrc".source = flakeRoot + /config/vscode/.vimrc;
        })

        (lib.mkIf (cfg.zed.enable or false) {
          programs.zed-editor = {
            enable = true;
          };
        })

      ]
    );
}
