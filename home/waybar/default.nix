{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

with lib;

let
  base = import ./settings.nix;
  modules = import ./modules.nix;
in
{
  programs.waybar = {
    enable = true;
    style = readFile ./waybar.css;
    settings = [
      (base // modules)
    ];
  };

  # Used by waybar
  home.packages = with pkgs; [
    playerctl
    pamixer
    cava
    nvtopPackages.full
    pavucontrol # Audio control
  ];
}
