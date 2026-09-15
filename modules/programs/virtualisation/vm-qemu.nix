# QEMU/KVM: system daemon + per-user clients (`homeManager.vm-qemu`).
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

      # libvirt 12.7 ships `LoadCredentialEncrypted` for secrets we don't use;
      # reset it (see `attrsToSection` in nixos/lib/systemd-lib.nix).
      systemd.services.libvirtd.serviceConfig.LoadCredentialEncrypted = lib.mkForce [ "" ];

      environment.systemPackages = [
        # libvirt bundles its own copy for NAT; this one is for manual use.
        pkgs.dnsmasq
      ];
    };

  flake.modules.homeManager.vm-qemu =
    { pkgs, ... }:

    {
      home.packages = [
        pkgs.virt-viewer
        pkgs.spice
        pkgs.spice-gtk
      ];
    };
}
