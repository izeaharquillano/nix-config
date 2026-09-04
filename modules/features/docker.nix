{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.features.docker;
in
{
  options.features.docker = {
    enable = lib.mkEnableOption "Docker container runtime";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = false;
      autoPrune.enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    users.users.${config.mySystem.username}.linger = true;

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    virtualisation.containers.registries.search = [
      "docker.io"
        "quay.io"
    ];

    environment.systemPackages = with pkgs; [
      distrobox
    ];
  };
}
