# Simple Aspect: XDG dirs, Nemo, GTK/Papirus, Qt, dconf
# Dendritic module: flake.modules.homeManager.home-linux-desktop
{
  flake.modules.homeManager.home-linux-desktop =
    { pkgs, ... }:

    {
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };

      xdg.desktopEntries.nemo = {
        name = "Nemo";
        exec = "${pkgs.nemo-with-extensions}/bin/nemo";
        icon = "nemo";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "nemo.desktop" ];
          "application/x-gnome-saved-search" = [ "nemo.desktop" ];
        };
        defaultApplicationPackages = with pkgs; [
          qimgv
        ];
      };

      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        Unit = {
          Description = "polkit-gnome-authentication-agent-1";
          Wants = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      home.pointerCursor = {
        enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
      };

      gtk = {
        enable = true;
        theme.name = "Adwaita";
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };

      qt = {
        enable = true;
        style.name = "adwaita-dark";
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita";
          icon-theme = "Papirus-Dark";
        };
        "org/cinnamon/desktop/applications/terminal" = {
          exec = "${pkgs.kitty}/bin/kitty";
        };
      };
    };
}
