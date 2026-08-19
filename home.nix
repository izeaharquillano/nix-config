{ pkgs, inputs, ... }:
{
  home.stateVersion = "26.05";
  home.username = "ize";
  home.homeDirectory = "/home/ize";

  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.niri.homeModules.niri
  ];

  # programs.niri.settings = {
  #   input.keyboard.xkb.layout = "us";
  #   outputs."eDP-1".scale = 1.0;
  # };

  home.packages = with pkgs; [
    # utils
    fd
    fzf
    gcc
    curl
    unzip

    # terminal tools
    zoxide
    lazygit
    ripgrep
    opencode

    # DE packages
    waybar
    fuzzel
    brightnessctl
    xwayland-satellite

    # fonts
    nerd-fonts.jetbrains-mono

    # apps
    ghostty
  ];

  programs = {
    npm.enable = true;
    zen-browser.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        svim = "sudoedit";
        bldswc = "sudo nixos-rebuild switch";
        bldflk = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
        nixgarb = "sudo nix-collect-garbage";
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
    git.settings = {
      userName = "Izeah Arquillano";
      userEmail = "izeaharquillano@gmail.com";
    };
  };

  xdg.configFile = {
    "niri/config.kdl".source = ./modules/niri/config.kdl;
    "ghostty/config".source = ./modules/ghostty/config;
    "nvim" = {
      source = ./modules/nvim;
      recursive = true;
    };
    "hypr" = {
      source = ./modules/hypr;
      recursive = true;
    };
    "rofi" = {
      source = ./modules/rofi;
      recursive = true;
    };
    "waybar" = {
      source = ./modules/waybar;
      recursive = true;
    };
  };
}
