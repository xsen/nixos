{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./waybar
    ./zsh.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  wayland.windowManager.hyprland.systemd.enable = false;

  catppuccin = {
    enable = true;
    flavor = "mocha";

    gtk = {
      enable = true;
      icon.enable = true;
    };

    cursors = {
      enable = true;
      accent = "blue";
    };
  };

  services = {
    mako = {
      enable = true;
      width = 600;
      padding = "20";
      defaultTimeout = 10000;
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

  programs = {
    btop = {
      enable = true;
      package = pkgs.btop.override { cudaSupport = true; };
    };
    kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 14;
      };
      settings = {
        confirm_os_window_close = 0;
        background_opacity = 0.8;
        window_padding_width = 8;
      };
      shellIntegration.enableZshIntegration = true;
    };
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      extraConfig = {
        modi = "run,calc,drun,window,emoji:rofimoji";
        icon-theme = "Oranchelo";
        show-icons = true;
        drun-display-format = "{icon} {name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-filebrowser = " 🗐  Files ";
        display-calc = " 🖩  Calc ";
        display-window = " 﩯  Window ";
        sidebar-mode = true;
        location = 0;
      };
      plugins = with pkgs; [
        rofimoji
        (rofi-calc.override { rofi-unwrapped = rofi-wayland-unwrapped; })
      ];
    };
    vim = {
      enable = true;
      settings = {
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        relativenumber = true;
      };
      extraConfig = ''
        set smarttab
        set softtabstop=2
      '';
    };
  };

  home = {
    sessionPath = [
      "$HOME/.npm-packages"
      "$HOME/.local/share/JetBrains/Toolbox/scripts"
    ];
    file = {
      ".ideavimrc".source = ./ideavimrc;
      ".npmrc".source = ./npmrc;
      ".config/hypr".source = ./hypr;
      ".local/share/applications/startup.desktop".source = ./startup/startup.desktop;
      ".scripts/startup.sh".source = ./startup/startup.sh;
    };

    packages = with pkgs; [
      yandex-music
      yandex-browser-stable
      hyprcursor
      hyprsunset
      hyprpaper
      hyprshot
      hyprlock
      hypridle
      satty
      rofimoji
      rofi-calc
      telegram-desktop
      google-chrome
      blueberry
      keepassxc
      obsidian
      ticktick
      nekoray
      discord
      libreoffice-qt
      yandex-disk
      haruna
      qbittorrent
      viewnior
      jq
    ];
  };
}
