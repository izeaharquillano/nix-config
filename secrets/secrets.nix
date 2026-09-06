let
  padrick = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjana/g5vxpaSS5OHe0HfN+eVkFtc9WzuCKCtbTQhcp root@padrick";
  jobert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDwOimLkLULeahLXIwCuhE3GHC/rbtbcA+8fsZQC4GG root@jobert";
  systems = [
    padrick
    jobert
  ];
in
{
  "nix-access-tokens.age".publicKeys = systems;
  "netbird-setup-key.age".publicKeys = systems;
}
