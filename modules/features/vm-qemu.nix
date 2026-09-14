# QEMU/KVM (libvirtd, virt-manager, SPICE).
{
  flake.modules.nixos.vm-qemu =
    {
      pkgs,
      lib,
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

      # libvirt 12.7+ 10-secret.conf sets LoadCredentialEncrypted; we don't use
      # secrets, so reset with `LoadCredentialEncrypted=` ([""] -> attrsToSection in nixos/lib/systemd-lib.nix).
      systemd.services.libvirtd.serviceConfig.LoadCredentialEncrypted = lib.mkForce [ "" ];

      environment.systemPackages = [
        pkgs.dnsmasq
        pkgs.virt-viewer
        pkgs.spice
        pkgs.spice-vdagent
        pkgs.spice-gtk
      ];
    };
}
