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

  home.packages = with pkgs; [
    hyprcursor
  ];

}
