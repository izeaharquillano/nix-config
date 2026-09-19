{
  flake.modules.nixos.dotnet =
    { pkgs, ... }:
    let
      dotnetRoot = "${pkgs.dotnetCorePackages.dotnet_10.sdk}/share/dotnet";
    in
    {
      environment.systemPackages = [
        pkgs.dotnetCorePackages.dotnet_10.sdk
      ];

      # Apphosts only probe FHS locations (`/usr/share/dotnet`,
      # `/etc/dotnet/install_location*`); point them at the store.
      environment = {
        sessionVariables = {
          DOTNET_ROOT = dotnetRoot;
          DOTNET_ROOT_X64 = dotnetRoot;
        };
        etc."dotnet/install_location".text = dotnetRoot;
        etc."dotnet/install_location_x64".text = dotnetRoot;
      };
    };

  flake.modules.homeManager.dotnet =
    { pkgs, ... }:
    {
      programs.vscode.profiles.default.extensions = [
        pkgs.vscode-extensions.ms-dotnettools.csharp
        pkgs.vscode-extensions.ms-dotnettools.vscode-dotnet-runtime
        pkgs.vscode-extensions.ms-dotnettools.csdevkit
      ];
    };
}
