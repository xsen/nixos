{ pkgs, ... }:
{

  catppuccin = {
    enable = true;
    flavor = "macchiato";

    pointerCursor = {
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
    catppuccin.enable = true;
    catppuccin.icon.enable = true;
  };

  programs = {
    kitty = {
      catppuccin.enable = true;

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

    waybar.catppuccin.enable = true;

    rofi = {
      enable = true;
      catppuccin.enable = true;
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
  };

  home.packages = with pkgs; [
    hyprcursor
  ];

}
