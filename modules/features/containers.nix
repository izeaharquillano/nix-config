{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.features.containers;
in
{
  options.features.containers = {
    enable = lib.mkEnableOption "Containers (docker, distrobox)";
    docker = {
      enable = lib.mkEnableOption "Docker (rootless)" // {
        default = true;
      };
    };
    distrobox = {
      enable = lib.mkEnableOption "Distrobox" // {
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = lib.mkIf cfg.docker.enable {
      enable = false;
      autoPrune.enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    users.users.${config.mySystem.username}.linger = lib.mkIf cfg.docker.enable true;

    virtualisation.containers.registries.settings = lib.mkIf cfg.docker.enable {
      unqualified-search-registries = [
        "docker.io"
        "quay.io"
      ];
    };

    virtualisation.podman = lib.mkIf cfg.distrobox.enable {
      enable = true;
      dockerCompat = true;
    };

    environment.systemPackages = (
      lib.optionals cfg.distrobox.enable (
        with pkgs;
        [
          distrobox
        ]
      )
    );
  };
}
