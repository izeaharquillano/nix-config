# Podman daemon + HM Distrobox CLI.
{
  flake.modules.nixos.podman = _: {
    virtualisation = {
      # Unqualified pulls (docker-compat).
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
  };

  flake.modules.homeManager.podman =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.distrobox ];
    };
}
