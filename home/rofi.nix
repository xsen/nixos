{ pkgs, ... }:
{
  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      location = "center";
      extraConfig = {
        show-icons = true;
        icon-theme = "Oranchelo";
        kb-row-select = "";
        kb-row-tab = "";
        matching = "fuzzy";
        sort = true;

        modi = "run,calc,drun,window,emoji:rofimoji";
        drun-display-format = "{icon} {name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-emoji = "   Emoji ";
        display-run = "   Run ";
        display-filebrowser = " 🗐  Files ";
        display-calc = " 🖩  Calc ";
        display-window = "   Window ";
        sidebar-mode = true;
        location = 0;
      };

      plugins = with pkgs; [
        rofimoji
        (rofi-calc.override { rofi-unwrapped = rofi-wayland-unwrapped; })
      ];
    };
  };
}

