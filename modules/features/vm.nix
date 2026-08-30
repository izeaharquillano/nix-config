{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.myfeatures.vm;
in
{
  options.myfeatures.vm = {
    enable = lib.mkEnableOption "QEMU/KVM virtualization with virt-manager";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };

    virtualisation.spiceUSBRedirection.enable = true;

    programs.virt-manager.enable = true;

    users.users.ize.extraGroups = [ "libvirtd" ];

    environment.systemPackages = with pkgs; [
      virt-viewer
      spice
      spice-vdagent
      spice-gtk
    ];
  };
}
