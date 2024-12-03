{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    home-manager
    pciutils
    nixfmt-rfc-style
    wget
    curl
    git

    vim
    neovim

    zip
    zoxide
    neofetch
    btop
    eza
    fzf

    lm_sensors

    ripgrep
    tldr
    unzip
    openssl
    openssl.dev

    #gnumake
    glib
    pkg-config
  ];

}
