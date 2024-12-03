{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable

    telegram-desktop
    google-chrome
    keepassxc
    obsidian

    libreoffice-qt
    yandex-disk

    #pkgs.steam
    #pkgs.steam-run
    #(pkgs.lutris.override {
      #extraPkgs = pkgs: [
        #pkgs.wineWowPackages.stable
        #pkgs.winetricks
      #];
    #})

    #pkgs.qbittorrent

    pkgs.viewnior
    #pkgs-unstable.hyprshot
    #pkgs.catppuccin-cursors.macchiatoBlue
    #pkgs.catppuccin-gtk
    #pkgs.papirus-folders
  ];

}
