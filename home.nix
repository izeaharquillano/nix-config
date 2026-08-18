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
    fd
    fzf
    gcc
    curl
    unzip
    zoxide
    waybar
    fuzzel
    lazygit
    ghostty
    ripgrep
    brightnessctl
    xwayland-satellite
    nerd-fonts.jetbrains-mono
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
    "nvim" = {
      source = ./modules/nvim;
      recursive = true;
    };
  };
}
