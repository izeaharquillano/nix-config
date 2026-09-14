# Simple Aspect: containers (Podman, Distrobox; Docker off by default).
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.containers
{
  flake.modules.nixos.containers =
    { pkgs, username, ... }:

    {
      virtualisation = {
        docker.enable = false;
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
      users.users.${username}.linger = true;
      environment.systemPackages = with pkgs; [ distrobox ];
    };
}
