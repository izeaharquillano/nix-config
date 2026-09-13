# Simple Aspect: containers (Docker rootless, Podman, Distrobox).
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.containers
{
  flake.modules.nixos.containers =
    { pkgs, config, ... }:

    {
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

      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };
      environment.systemPackages = with pkgs; [ distrobox ];
    };
}
