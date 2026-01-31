{ pkgs, ... }:
{
  programs = {
    zsh.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    throne = {
      enable = true;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    throne
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
    wl-clipboard
    pcmanfm-qt
    peazip
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
    pyprland
    hypridle
    satty
    telegram-desktop
    google-chrome
    blueberry
    keepassxc
    ticktick
    discord
    libreoffice-qt
    koreader
    figma-linux
    haruna
    qbittorrent
    viewnior
    jq
    nh
#    openshot-qt
    (obsidian.override (old: {
      commandLineArgs = "--disable-gpu-compositing";
    }))
  ];
}
