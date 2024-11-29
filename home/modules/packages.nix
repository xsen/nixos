{ pkgs, inputs, ... }: {

  home.packages = [
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable

    pkgs.telegram-desktop
    pkgs.google-chrome
    pkgs.keepassxc
    pkgs.obsidian

    pkgs.libreoffice-qt


    pkgs.steam
    pkgs.steam-run
    (pkgs.lutris.override {
      extraPkgs = pkgs: [
        pkgs.wineWowPackages.stable
        pkgs.winetricks
      ];
    })

    #pkgs.qbittorrent


    pkgs.viewnior
    #pkgs-unstable.hyprshot
    pkgs.catppuccin-cursors.macchiatoBlue
    pkgs.catppuccin-gtk
    pkgs.papirus-folders
  ];

}
