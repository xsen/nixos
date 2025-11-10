{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./packages.nix
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    gtk.icon.enable = true;

    cursors = {
      enable = true;
      accent = "blue";
    };
  };

  services = {
    mako = {
      enable = true;
      settings = {
        width = 600;
        padding = "20";
        default-timeout = 10000;
      };
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  gtk = {
    enable = true;
  };

  home = {
    activation = {
      setupWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ~/.wallpapers

        if [ ! -f ~/.wallpapers/default.png ]; then
          cp --no-clobber "${./images/wallpaper-default.png}" ~/.wallpapers/default.png
        fi

        if [ ! -e ~/.wallpapers/current.png ]; then
          ln -sf "${./images/wallpaper-default.png}" ~/.wallpapers/current.png
        fi
      '';
    };
    sessionVariables = {
      EDITOR = "vim";
      BROWSER = "yandex-browser-stable";
      TERMINAL = "kitty";
      NH_OS_FLAKE = "$HOME/.nix-config";
    };
    sessionPath = [
      "$HOME/.scripts"
      "$HOME/.npm-packages"
      "$HOME/.local/share/JetBrains/Toolbox/scripts"
      "$HOME/.config/composer/vendor/bin"
    ];
    file = {
      ".npmrc".source = ./npmrc;
#      ".ideavimrc".source = ./ideavimrc;
      ".config/hypr".source = ./hypr;

      ".scripts/smart-screenshot.sh" = {
        source = ./scripts/smart-screenshot.sh;
        executable = true;
      };
      ".scripts/switch-layout" = {
        source = ./scripts/switch-layout.sh;
        executable = true;
      };
      ".scripts/launch-apps" = {
        source = ./scripts/launch-apps.sh;
        executable = true;
      };
      ".scripts/change-wallpaper" = {
        source = ./scripts/change-wallpaper.sh;
        executable = true;
      };

      ".local/share/icons/start-apps-icon.png".source = ./images/start-apps-icon.png;
      ".local/share/applications/launch-apps.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Launch Apps
        Comment=Launches common applications
        Icon=${config.home.homeDirectory}/.local/share/icons/start-apps-icon.png
        Exec=${config.home.homeDirectory}/.scripts/launch-apps
        StartupNotify=false
      '';
    };
  };
}
