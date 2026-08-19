{ config, pkgs, ... }:

{
  imports =
    [
    ./hardware-configuration.nix
    ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 10;

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
      configurationLimit = 5;
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
    blueman.enable = true;

    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          # command = "${config.programs.niri.package}/bin/niri-session";
          # user = "ize";
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
        };
      };
    };

    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        # START_CHARGE_THRESH_BAT0 = 75;
        # STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="platform::micmute", \
      RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys/class/leds/%k/brightness"
      '';
  };

  systemd.user.services.niri.enableDefaultPath = false;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

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
    (pkgs.writeShellScriptBin "micmute" ''
      wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
      echo 1 > /sys/class/leds/platform::micmute/brightness
      else
      echo 0 > /sys/class/leds/platform::micmute/brightness
      fi
    '')
  ];

  programs = {
    git = {
      enable = true;
      config = {
        user.name = "Izeah Arquillano";
        user.email = "izeaharquillano@gmail.com";
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
    hyprland.enable = true;
    nix-ld.enable = true;
  };

  nix.settings.experimental-features = ["nix-command" "flakes" ];

  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
  '';

  system.stateVersion = "26.05";
}
