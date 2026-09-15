# Docker rootless + Podman + Distrobox.
{
  flake.modules.nixos.containers =
    { pkgs, ... }:

    {
      virtualisation = {
        docker = {
          enable = false;
          autoPrune.enable = true;
          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };
        # Used by podman for unqualified pulls (docker-compat).
        containers.registries.settings = {
          unqualified-search-registries = [
            "docker.io"
            "quay.io"
          ];
        };

        podman = {
          enable = true;
          dockerCompat = true;
        };
      };
      environment.systemPackages = [ pkgs.distrobox ];
    };
}
