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
      };

      shellIntegration.enableZshIntegration = true;
    };

    waybar.catppuccin.enable = true;
  };

  home.packages = with pkgs; [
    hyprcursor
  ];

}
