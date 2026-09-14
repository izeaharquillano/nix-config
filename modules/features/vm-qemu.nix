# QEMU/KVM (libvirtd, virt-manager, SPICE).
{
  flake.modules.nixos.vm-qemu =
    {
      pkgs,
      username,
      ...
    }:

    {
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = false;
            swtpm.enable = true;
            vhostUserPackages = [ pkgs.virtiofsd ];
          };
        };
        spiceUSBRedirection.enable = true;
      };
      programs.virt-manager.enable = true;
      users.users.${username}.extraGroups = [ "libvirtd" ];
      networking.firewall.trustedInterfaces = [ "virbr0" ];

      # No libvirt secrets; plain assignment so hosts can override.
      systemd.services.libvirtd = {
        serviceConfig.LoadCredentialEncrypted = [ "" ];
      };

      environment.systemPackages = [
        pkgs.dnsmasq
        pkgs.virt-viewer
        pkgs.spice
        pkgs.spice-vdagent
        pkgs.spice-gtk
      ];
    };
}
