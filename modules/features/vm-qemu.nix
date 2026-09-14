# Simple Aspect: QEMU/KVM virtual machines (libvirtd, virt-manager, SPICE).
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.vm-qemu
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

      # libvirt 12.7+ ships a 10-secret.conf drop-in with
      # LoadCredentialEncrypted for secrets encryption. Since we don't
      # use libvirt secrets, clear the credential loading to prevent
      # failures when the systemd credential decryption key is unavailable.
      systemd.services.libvirtd = {
        serviceConfig.LoadCredentialEncrypted = lib.mkForce [ "" ];
      };

      environment.systemPackages = with pkgs; [
        dnsmasq
        virt-viewer
        spice
        spice-vdagent
        spice-gtk
      ];
    };
}
