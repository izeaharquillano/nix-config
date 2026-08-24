{ ... }:

{
  services.netbird.clients.default = {
    port = 51820;
    ui.enable = true;

    login = {
      enable = true;
      setupKeyFile = "/etc/netbird/setup-key";
    };

    openFirewall = true;
    openInternalFirewall = true;
  };
}
