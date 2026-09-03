{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.sysfeatures.vm;
in
{
  options.sysfeatures.vm = {
    enable = lib.mkEnableOption "QEMU/KVM, virt-manager, bottles";
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

    users.users.${config.mySystem.username}.extraGroups = [ "libvirtd" ];

    environment.systemPackages = with pkgs; [
      virt-viewer
      spice
      spice-vdagent
      spice-gtk
      dosbox
      (bottles.override { removeWarningPopup = true; })
    ];
  };
}
