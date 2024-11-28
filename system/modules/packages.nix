{ config, inputs, pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    git
    vim 

    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
    telegram-desktop
    google-chrome
    keepassxc
  ];

}
