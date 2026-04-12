{ pkgs, ... }:
{
  programs = {
    fish.enable = true;
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
    nixfmt
    wget
    curl
    git
    vim
    zip
    p7zip
    zoxide
    yazi
    fastfetch
    eza
    fzf
    bat
    libcap
    lm_sensors
    ripgrep
    tldr
    unzip
    ghostty
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
    hypridle
    satty
    telegram-desktop
    google-chrome
    firefox
    blueman
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
    # openshot-qt
    ffmpeg_6-full
    (obsidian.override (old: {
      commandLineArgs = "--disable-gpu-compositing";
    }))
  ];
}
