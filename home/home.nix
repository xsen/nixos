{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  nixConfigDir = "${config.home.homeDirectory}/Code/nixos/xsen";
in
{
  imports = [
    ./packages.nix
    ./hypr/hypr-config.nix
    ./swaync.nix
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    gtk.icon.enable = true;

    cursors = {
      enable = true;
      accent = "blue";
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  gtk = {
    enable = true;
    gtk4.theme = null;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-enable-primary-paste = true;
    };
  };

  xdg = {
    desktopEntries."ghostty-yazi" = {
      name = "Yazi File Manager (Ghostty)";
      exec = "ghostty -e yazi %f";
      terminal = false;
      mimeType = [ "inode/directory" ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/markdown" = [ "dev.zed.Zed.desktop" "nvim.desktop" ];
        "text/x-markdown" = [ "dev.zed.Zed.desktop" "nvim.desktop" ];
        "application/json" = [ "dev.zed.Zed.desktop" "gvim.desktop" ];
        "text/html" = [ "yandex-browser.desktop" ];
        "x-scheme-handler/http" = [ "yandex-browser.desktop" ];
        "x-scheme-handler/https" = [ "yandex-browser.desktop" ];
        "x-scheme-handler/about" = [ "yandex-browser.desktop" ];
        "x-scheme-handler/unknown" = [ "yandex-browser.desktop" ];
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/jetbrains" = [ "jetbrainsd.desktop" ];
        "x-scheme-handler/mailto" = [ "yandex-browser.desktop" ];
        "x-scheme-handler/figma" = [ "figma-linux.desktop" ];
        "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
        "inode/directory" = [ "ghostty-yazi.desktop" ];
      };
      associations = {
        added = {
          "image/png" = [ "viewnior.desktop" ];
          "x-scheme-handler/tg" = [ "org.telegram.telegram-desktop" "org.telegram.desktop.desktop" ];
          "x-scheme-handler/tonsite" = [ "org.telegram.telegram-desktop" "org.telegram.desktop.desktop" ];
          "application/json" = [ "dev.zed.Zed.desktop" "gvim.desktop" "yandex-browser.desktop" ];
          "text/plain" = [ "jetbrains-phpstorm-48772c4e-b18a-4415-ba39-fbfad2359cfa.desktop" "gvim.desktop" "writer.desktop" ];
          "image/jpeg" = [ "yandex-browser.desktop" ];
        };
      };
    };
  };

  home = {
    enableNixpkgsReleaseCheck = false;
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
      TERMINAL = "ghostty";
      NH_FLAKE = "$HOME/.nix-config";
    };
    sessionPath = [
      "$HOME/.scripts"
      "$HOME/.npm-packages"
      "$HOME/.local/share/JetBrains/Toolbox/scripts"
      "$HOME/.config/composer/vendor/bin"
    ];
    file = {
      ".npmrc".source = ./npmrc;

      # Out-of-store symlinks for mutable configuration files (accessible for agents/user without rebuilding)
      ".config/zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/zed/settings.json";
      ".config/zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/zed/keymap.json";
      ".config/zed/tasks.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/zed/tasks.json";

      ".gemini/config/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/AGENTS.md";
      ".gemini/config/mcp_config.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/mcp_config.json";
      ".gemini/config/instructions.md".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/instructions.md";
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
