{ pkgs, inputs, ... }:
let
  nixFlakePath = "/home/evgeny/Code/nixos/xsen";
in
{

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "history"
          #"wd"
        ];
      };
      initExtra = ''
        ZSH_THEME="catppuccin";
        CATPPUCCIN_FLAVOR="macchiato";
        source ~/.config/.oh-my-zsh/catppuccin.zsh-theme;
      '';
      shellAliases = {
        cat = "bat";
        ls = "eza --icons=always";
        nx-clean = ''
          sudo nix-collect-garbage -d
          home-manager expire-generations "now"
        '';
        nx-rebuild = "sudo nixos-rebuild switch --flake ${nixFlakePath} && home-manager switch --flake ${nixFlakePath}";
        nx-flake = "sudo nixos-rebuild switch --flake ${nixFlakePath}";
        nx-home = "home-manager switch --flake ${nixFlakePath}";
      };
    };
    vim = {
      enable = true;
      settings = {
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        relativenumber = true;
      };
      extraConfig = ''
        set smarttab
        set softtabstop=2
      '';
    };

    kitty = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable

    telegram-desktop
    google-chrome
    keepassxc
    obsidian
    ticktick
    #anydesk

    nekoray
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

    viewnior
    #pkgs-unstable.hyprshot
  ];

}
