# Docker rootless: `enable = false` is REQUIRED (daemon runs as a user
# service instead). See https://wiki.nixos.org/wiki/Docker#Rootless.
# With `nixos.podman`: user shells hit the Docker daemon (`$DOCKER_HOST`);
# socket-default clients hit Podman's `/var/run/docker.sock` compat symlink.
{
  flake.modules.nixos.docker = {
    virtualisation.docker = {
      enable = false;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
