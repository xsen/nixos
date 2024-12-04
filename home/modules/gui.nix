{ pkgs, ... }:
{

  catppuccin.enable = true;
  catppuccin.flavor = "macchiato";
  catppuccin.pointerCursor.enable = true;

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  gtk = {
    enable = true;
    catppuccin.enable = true;
  };

  home.packages = with pkgs; [
    hyprcursor
  ];
}
