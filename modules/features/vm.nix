{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.features.vm;
in
{
  options.features.vm = {
    enable = lib.mkEnableOption "Virtual machine support";
    qemu = {
      enable = lib.mkEnableOption "QEMU/KVM, virt-manager, and SPICE tools" // {
        default = true;
      };
    };
    bottles = {
      enable = lib.mkEnableOption "Bottles (Wine runner)" // {
        default = true;
      };
    };
    dosbox = {
      enable = lib.mkEnableOption "DOSBox emulator" // {
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = lib.mkIf cfg.qemu.enable {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };

    virtualisation.spiceUSBRedirection.enable = lib.mkIf cfg.qemu.enable true;

    programs.virt-manager.enable = lib.mkIf cfg.qemu.enable true;

    users.users.${config.mySystem.username}.extraGroups = lib.optionals cfg.qemu.enable [ "libvirtd" ];

    environment.systemPackages =
      (lib.optionals cfg.qemu.enable (
        with pkgs;
        [
          virt-viewer
          spice
          spice-vdagent
          spice-gtk
        ]
      ))
      ++ (lib.optionals cfg.bottles.enable [
        (pkgs.bottles.override { removeWarningPopup = true; })
      ])
      ++ (lib.optionals cfg.dosbox.enable [ pkgs.dosbox ]);
  };
}
