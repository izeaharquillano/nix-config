{ inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;

      ExtensionSettings = {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    env = {
      GTK_THEME = "Adwaita";
    };

    profiles.default = {
      settings = {
        "zen.welcome-screen.seen" = true;
        "zen.view.sidebar-expanded" = false;
      };

      mods = [
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better find bar
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better unloaded tabs
      ];

      containersForce = true;
      containers = { };

      spacesForce = true;
      spaces = {
        "General" = {
          id = "ca734165-bae8-417c-a825-75d31c0923d9";
          position = 1000;
          icon = "💤";
          theme = {
            type = "gradient";
            colors = [{
              red = 60;
              green = 56;
              blue = 54;
            }];
          };
        };
        "Work" = {
          id = "c3a7d364-1285-478d-8617-6e8e1d28fdba";
          position = 2000;
          icon = "💼";
          theme = {
            type = "gradient";
            colors = [{
              red = 60;
              green = 56;
              blue = 54;
            }];
          };
        };
        "Presentation" = {
          id = "08dc384f-72db-4395-b2bc-57b460b9ca73";
          position = 3000;
          icon = "🎥";
          theme = {
            type = "gradient";
            colors = [{
              red = 60;
              green = 56;
              blue = 54;
            }];
          };
        };
      };

      pinsForce = true;
      pinsForceAction = "remove";
      pins = {
        "Messenger" = {
          id = "02857fd6-cd53-45a5-b8d9-54e3c2064a0c";
          url = "https://www.facebook.com/messages";
          position = 101;
        };
      };

      extensionButtons = {
        "nav-bar" = [
          "{446900e4-71c2-419f-a6a7-df9c091e268b}"
        ];
      };

      keyboardShortcutsVersion = 20;
      keyboardShortcuts = [
        {
          id = "zen-workspace-forward";
          key = "j";
          modifiers = {
            control = true;
            alt = true;
          };
        }
        {
          id = "zen-workspace-backward";
          key = "k";
          modifiers = {
            control = true;
            alt = true;
          };
        }
      ];
    };
  };
}
