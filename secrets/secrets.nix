let
  padrick = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXNwpuUhP9UdRk4oVjl9Bzva/sWiXkiD7HMrY4NcgOZ root@padrick";
  jobert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDwOimLkLULeahLXIwCuhE3GHC/rbtbcA+8fsZQC4GG root@jobert";
  systems = [
    padrick
    jobert
  ];
in
{
  "nix-access-tokens.age".publicKeys = systems;
  "netbird-setup-key.age".publicKeys = systems;
  "zerotier-network-id.age".publicKeys = systems;
}
