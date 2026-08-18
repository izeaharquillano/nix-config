{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    
    systemd-boot = {
      enable = true;
      
      windows = {
        "windows" =
         let
           boot-drive = "HD0b";
         in
         {
           title = "Windows Boot Manager";
           efiDeviceHandle = boot-drive;
           sortKey = "y_windows";
         };
      };

      edk2-uefi-shell.enable = true;
      edk2-uefi-shell.sortKey = "z_edk2";  
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024;
  }];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Manila";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_PH.UTF-8";
    LC_IDENTIFICATION = "en_PH.UTF-8";
    LC_MEASUREMENT = "en_PH.UTF-8";
    LC_MONETARY = "en_PH.UTF-8";
    LC_NAME = "en_PH.UTF-8";
    LC_NUMERIC = "en_PH.UTF-8";
    LC_PAPER = "en_PH.UTF-8";
    LC_TELEPHONE = "en_PH.UTF-8";
    LC_TIME = "en_PH.UTF-8";
  };

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
	  command = "${config.programs.niri.package}/bin/niri-session";
	  user = "ize";
	};
      };
    };
  };

  systemd.user.services.niri.enableDefaultPath = false;

  users.users."ize" = {
    isNormalUser = true;
    description = "ize";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    btop
    tmux
    fastfetch
    xdg-user-dirs
  ];

  programs = {
    git = {
      enable = true;
      config = {
        # user.name = "";
	# user.email = "";
      };
    };
    bash.shellAliases = {
      svim = "sudoedit";
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    niri.enable = true;
  };

  nix.settings.experimental-features = ["nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
