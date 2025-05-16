{ pkgs, ... }:
{
  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      location = "center";
      font = "JetBrainsMono Nerd Font 16";
      extraConfig = {
        show-icons = true;
        kb-row-select = "";
        kb-row-tab = "";

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
      };

      plugins = with pkgs; [
        rofimoji
        (rofi-calc.override { rofi-unwrapped = rofi-wayland-unwrapped; })
      ];
    };
  };

  home.file = {
    ".config/rofi/custom.rasi".source = ./custom.rasi;
  };
}
