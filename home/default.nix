{
  username,
  pkgs,
  inputs,
  ...
}:
let
  configDir = ./dotfiles;
  nixFlakePath = "/home/${username}/Code/nixos/xsen";
in
{
  imports = [
    ./waybar
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";

    pointerCursor = {
      enable = true;
      accent = "blue";
    };
  };

  services = {
    mako = {
      enable = true;
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  gtk = {
    enable = true;
    catppuccin.enable = true;
    catppuccin.icon.enable = true;
  };

  programs = {
    btop.enable = true;
    kitty = {
      enable = true;
      font = {
        name = "Jetbrains Mono Nerd Font";
        size = 14;
      };
      settings = {
        confirm_os_window_close = 0;
        background_opacity = 0.8;
        window_padding_width = 8;
      };
      shellIntegration.enableZshIntegration = true;
    };

    waybar = {
      enable = true;
    };

    rofi = {
      enable = true;
      extraConfig = {
        modi = "run,calc,drun,window";
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
      plugins = [
        pkgs.rofimoji
        pkgs.rofi-calc
      ];
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "history"
          #"wd"
        ];
      };
      initExtra = ''
        ZSH_THEME="catppuccin";
        CATPPUCCIN_FLAVOR="mocha";
        source ~/.config/.oh-my-zsh/catppuccin.zsh-theme;
      '';
      shellAliases = {
        cat = "bat";
        ls = "eza --icons=always";
        nx-clean = ''
          sudo nix-collect-garbage -d
          home-manager expire-generations "now"
        '';
        nx-rebuild = "sudo nixos-rebuild switch --flake ${nixFlakePath} && home-manager switch --flake ${nixFlakePath}";
        nx-flake = "sudo nixos-rebuild switch --flake ${nixFlakePath}";
        nx-home = "home-manager switch --flake ${nixFlakePath}";
      };
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
      "/home/${username}/.local/share/JetBrains/Toolbox/scripts"
    ];
    sessionVariables = {
      BROWSER = "yandex-browser-stable";
      EDITOR = "vim";
      TERMINAL = "kitty";
    };
    file = {
      ".ideavimrc".source = "${configDir}/ideavimrc";
      ".config/hypr".source = "${configDir}/hypr";
      ".config/.oh-my-zsh" = {
        recursive = true;
        source = "${configDir}/catppuccin-zsh/";
      };
    };

    packages = with pkgs; [
      inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
      hyprshot
      hyprlock
      hypridle
      satty
      rofi-calc
      rofimoji
      telegram-desktop
      google-chrome
      keepassxc
      obsidian
      ticktick
      anydesk
      nekoray
      discord
      libreoffice-qt
      yandex-disk
      jetbrains-toolbox
      steam
      steam-run
      (lutris.override {
        extraPkgs = pkgs: [
          wineWowPackages.stable
          winetricks
        ];
      })
      qbittorrent
      viewnior
    ];
  };
}
