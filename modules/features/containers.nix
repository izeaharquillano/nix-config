# Conditional Aspect: Docker rootless, Podman, Distrobox
# Dendritic module: flake.modules.nixos.containers
{
  flake.modules.nixos.containers =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      cfg = config.features.containers;
      mkEnabledOption = desc: lib.mkEnableOption desc // { default = true; };
    in
    {
      options.features.containers = {
        enable = lib.mkEnableOption "Containers (docker, distrobox)";
        docker.enable = mkEnabledOption "Docker (rootless)";
        distrobox.enable = mkEnabledOption "Distrobox";
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [

          (lib.mkIf cfg.docker.enable {
            virtualisation.docker = {
              enable = false;
              autoPrune.enable = true;
              rootless = {
                enable = true;
                setSocketVariable = true;
              };
            };
            users.users.${config.mySystem.username}.linger = true;
            virtualisation.containers.registries.settings = {
              unqualified-search-registries = [
                "docker.io"
                "quay.io"
              ];
            };
          })

          (lib.mkIf cfg.distrobox.enable {
            virtualisation.podman = {
              enable = true;
              dockerCompat = true;
            };
            environment.systemPackages = with pkgs; [ distrobox ];
          })

        ]
      );
    };
}
