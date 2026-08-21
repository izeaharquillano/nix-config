{ pkgs, inputs, ... }:
{
  home.stateVersion = "26.05";
  home.username = "ize";
  home.homeDirectory = "/home/ize";

  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  home.packages = with pkgs; [
    # utils
    fd
    fzf
    gcc
    curl
    unzip

    # terminal tools
    btop
    fastfetch
    zoxide
    lazygit
    ripgrep
    opencode

    # DE packages
    fuzzel
    waybar
    pavucontrol
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

    # niri = {
    #   settings = {
    #     spawn-at-startup = [
    #       { command = [ "noctalia" ]; }
    #     ];
    #   };
    # };

    noctalia = {
      enable = true;
      settings = {
      };
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
      shellWrapperName = "y";
      flavors = {
        gruvbox-material = pkgs.fetchFromGitHub {
          owner = "matt-dong-123";
          repo = "gruvbox-material.yazi";
          rev = "main";
          hash = "sha256-mfIdFIe++jRDbTQBcLlpAq91JzmgL2SvqPxkYuCnKdQ=";
        };
      };
      theme.flavor = {
        dark = "gruvbox-material";
        light = "gruvbox-material";
      };
    };
  };

  xdg.configFile = {
    "niri/config.kdl".source = ./modules/niri/config.kdl;
    "ghostty/config".source = ./modules/ghostty/config;
    "tmux/tmux.conf".source = ./modules/tmux/tmux.conf;
    "fuzzel/fuzzel.ini".source = ./modules/fuzzel/fuzzel.ini;
    "nvim" = {
      source = ./modules/nvim;
      recursive = true;
    };
    "hypr" = {
      source = ./modules/hypr;
      recursive = true;
    };
  };
}
