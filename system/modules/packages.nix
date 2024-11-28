{ config, inputs, pkgs, ...}: {

  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    home-manager
    git
    wget
    kitty
    vim 
    wofi
    waybar
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
    telegram-desktop
    google-chrome
    keepassxc
  ];

}
