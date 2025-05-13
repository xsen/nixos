{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./packages.nix
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
      ".config/satty/config.toml".source = ./satty.toml; # ver 0.18.0 bugs https://github.com/gabm/Satty/issues/170
      ".npmrc".source = ./npmrc;
      ".config/hypr".source = ./hypr;
      ".local/share/applications/startup.desktop".source = ./startup/startup.desktop;
      ".scripts/startup.sh".source = ./startup/startup.sh;
    };
  };
}
