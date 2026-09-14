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

      # No libvirt secrets in use; clear credential loading (fails without key).
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
