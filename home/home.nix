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
    sessionVariables = {
      EDITOR = "vim";
      BROWSER = "yandex-browser-stable";
      TERMINAL = "kitty";
    };
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
      libva-utils
      vulkan-tools
      yandex-music
      yandex-browser-stable
      (obsidian.override (old: {
        commandLineArgs = "--disable-gpu-compositing";
      }))
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
      ticktick
      nekoray
      discord
      libreoffice-qt
      # todo: hotfix
      (yandex-disk.overrideAttrs (
        final: old:
        with pkgs;
        let
          p = {
            arch = "x86_64";
            gcclib = "${lib.getLib pkgs.stdenv.cc.cc}/lib";
            sha256 = "sha256-HH/pLZmDr6m/B3e6MHafDGnNWR83oR2y1ijVMR/LOF0=";
            webarchive = "20220519080155";
          };
        in
        {
          src = fetchurl {
            urls = [
              "https://repo.yandex.ru/yandex-disk/rpm/stable/${p.arch}/${final.pname}-${final.version}-1.fedora.${p.arch}.rpm"
              "https://web.archive.org/web/${p.webarchive}/https://repo.yandex.ru/yandex-disk/rpm/stable/${p.arch}/${final.pname}-${final.version}-1.fedora.${p.arch}.rpm"
            ];
            sha256 = p.sha256;
          };
          buildInputs = [
            zlib
            stdenv.cc.cc
          ];
          builder = writeText "builder.sh" (
            (builtins.readFile old.builder)
            + ''
              ${patchelf}/bin/patchelf \
                --set-rpath "${zlib.out}/lib:${p.gcclib}" \
                $out/bin/yandex-disk
            ''
          );
        }
      ))
#      yandex-disk
      haruna
      qbittorrent
      viewnior
      jq
    ];
  };
}
