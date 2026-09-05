{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.features.vm;
  mkEnabledOption = desc: lib.mkEnableOption desc // { default = true; };
in
{
  options.features.vm = {
    enable = lib.mkEnableOption "Virtual machine support";
    qemu.enable = mkEnabledOption "QEMU/virt-manager for virtual machines";
    bottles.enable = mkEnabledOption "Bottles for Windows compatibility layer";
    dosbox.enable = lib.mkEnableOption "DOSBOX for DOS emulation";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      (lib.mkIf cfg.qemu.enable {
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
        ];
      })

      (lib.mkIf cfg.bottles.enable {
        environment.systemPackages = with pkgs; [ (bottles.override { removeWarningPopup = true; }) ];
      })

      (lib.mkIf cfg.dosbox.enable {
        environment.systemPackages = with pkgs; [ dosbox ];
      })

    ]
  );
}
