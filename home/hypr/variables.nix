{ config, ... }:
let
  # Catppuccin Mocha colors (extracted from mocha.conf)
  # We use the Alpha version for the hex code without # for Hyprlock placeholder compatibility if needed,
  # but here we mostly need the full colors.
  colors = {
    rosewater = "rgb(f5e0dc)";
    flamingo = "rgb(f2cdcd)";
    pink = "rgb(f5c2e7)";
    mauve = "rgb(cba6f7)";
    mauveAlpha = "cba6f7";
    red = "rgb(f38ba8)";
    maroon = "rgb(eba0ac)";
    peach = "rgb(fab387)";
    yellow = "rgb(f9e2af)";
    green = "rgb(a6e3a1)";
    teal = "rgb(94e2d5)";
    sky = "rgb(89dceb)";
    sapphire = "rgb(74c7ec)";
    blue = "rgb(89b4fa)";
    lavender = "rgb(b4befe)";
    text = "rgb(cdd6f4)";
    textAlpha = "cdd6f4";
    subtext1 = "rgb(bac2de)";
    subtext0 = "rgb(a6adc8)";
    overlay2 = "rgb(9399b2)";
    overlay1 = "rgb(7f849c)";
    overlay0 = "rgb(6c7086)";
    surface2 = "rgb(585b70)";
    surface1 = "rgb(45475a)";
    surface0 = "rgb(313244)";
    base = "rgb(1e1e2e)";
    mantle = "rgb(181825)";
    crust = "rgb(11111b)";
  };
in
{
  inherit colors;

  settings = {
    terminal = "ghostty";
    fileManager = "pcmanfm-qt";
    browser = "yandex-browser-stable";
    font = "JetBrainsMono Nerd Font";
    wallpaper = "~/.wallpapers/current.png";
    accent = colors.mauve;
    accentAlpha = colors.mauveAlpha;
  };
}
