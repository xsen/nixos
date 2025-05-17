{ pkgs, ... }:
{
  programs = {
    zsh.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager
    pciutils
    nixfmt-rfc-style
    wget
    curl
    git
    vim
    zip
    p7zip
    zoxide
    yazi
    neofetch
    eza
    fzf
    bat
    libcap
    lm_sensors
    ripgrep
    tldr
    unzip
    kitty
    libnotify
    qt5.full
    qt6.full
    wl-clipboard
    xfce.thunar
    libva-utils
    vulkan-tools
    yandex-disk
    yandex-browser-stable
    hyprcursor
    hyprsunset
    hyprpaper
    tor-browser
    hyprshot
    hyprlock
    hypridle
    satty
    rofimoji
    rofi-calc
    telegram-desktop
    google-chrome
    blueberry
    keepassxc
    ticktick
    nekoray
    discord
    libreoffice-qt
    haruna
    qbittorrent
    viewnior
    jq
    nh
    (plexamp.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
      buildCommand = ''
        ${old.buildCommand}
        source "${makeWrapper}/nix-support/setup-hook"
        wrapProgram "$out/bin/plexamp" \
            --add-flags "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --use-gl=desktop"
      '';
    }))
    (obsidian.override (old: {
      commandLineArgs = "--disable-gpu-compositing";
    }))
  ];
}
