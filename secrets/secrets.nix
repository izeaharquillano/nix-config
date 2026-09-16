let
  padrick = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2/J/AGyj9j/Tc/0s7r8CmlV8cjohsSPH5oUBx1YJJI root@padrick";
  jobert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhwr6KHOBhirOrEpWhzNmPqZ6jrTADIkMsOxrVXKxXS root@jobert";
  recovery = "age14w3jsd5n24yhqr7yt9580u8c4uf5awh0hvs97ampxs274pk77qwsrnse3f";
  systems = [
    padrick
    jobert
    recovery
  ];
in
{
  "nix-access-tokens.age".publicKeys = systems;
  "netbird-setup-key.age".publicKeys = systems;
}
