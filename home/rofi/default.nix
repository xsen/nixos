{ pkgs, ... }:
{
  programs = {
    rofi = {
      enable = true;
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
        sorting-method = "fzf";
        sort = true;
        matching = "normal";
        drun-match-fields = "name,generic,keywords,categories";
      };

      plugins = with pkgs; [
        rofimoji
        (rofi-calc.override { rofi-unwrapped = rofi-unwrapped; })
      ];
    };
  };

  home = {
    file = {
      ".config/rofi/custom.rasi".source = ./custom.rasi;
    };
    packages = with pkgs; [
      rofimoji
      rofi-calc
    ];
  };
}
