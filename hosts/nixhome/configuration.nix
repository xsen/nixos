{ username, host, pkgs, inputs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/polkit.nix
    ../../modules/nix-ld.nix
  ];

  nix = {
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };

    initrd.kernelModules = [ "nvidia_drm" ];
  };

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  services = {
    dbus.enable = true;
    flatpak.enable = true;
    journald.extraConfig = "SystemMaxUse=1G";

    displayManager = {
      defaultSession = "hyprland";
      sddm = {
        enable = true;
        autoNumlock = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
      };
    };

    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "us,ru";
        options = "grp:caps_toggle,grp_led:caps";
      };
      displayManager = {
        sessionCommands = ''
          export LANG=ru_RU.UTF-8
          export LC_CTYPE="ru_RU.UTF-8"
          export LC_NUMERIC=ru_RU.UTF-8
          export LC_TIME=ru_RU.UTF-8
          export LC_COLLATE="ru_RU.UTF-8"
          export LC_MONETARY=ru_RU.UTF-8
          export LC_MESSAGES="ru_RU.UTF-8"
          export LC_PAPER=ru_RU.UTF-8
          export LC_NAME=ru_RU.UTF-8
          export LC_ADDRESS=ru_RU.UTF-8
          export LC_TELEPHONE=ru_RU.UTF-8
          export LC_MEASUREMENT=ru_RU.UTF-8
          export LC_IDENTIFICATION=ru_RU.UTF-8
        '';
      };
    };

    pipewire = {
      enable = true;
      jack.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  security = {
    rtkit.enable = true;
    pam.services.swaylock = { };
    pam.services.swaylock.fprintAuth = false;
  };

  environment.variables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    XDG_SESSION_TYPE = "wayland";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  networking = {
    hostName = host;

    nftables.enable = true;
    networkmanager.enable = true;

    firewall = {
      enable = true;
      checkReversePath = false;
    };
  };

  catppuccin.enable = true;
  catppuccin.flavor = "macchiato";

  time.timeZone = "Asia/Yekaterinburg";

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    #inputMethod = {
      #enabled = "fcitx5";
      #fcitx5.waylandFrontend = true;
      #fcitx5.addons = with pkgs; [
        #fcitx5-mozc
        #fcitx5-gtk
        #fcitx5-rime
      #];
    #};
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = "Evgeny";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    packages = with pkgs; [

    ];
  };

  console = {
    font = "ter-v32n";
    earlySetup = true;
    useXkbConfig = true;
    packages = [ pkgs.terminus_font ];
  };

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    terminus_font
    noto-fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  programs = {
    zsh.enable = true;

    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
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
    neovim

    zip
    zoxide
    neofetch
    btop
    eza
    fzf
    bat

    lm_sensors

    ripgrep
    tldr
    unzip
    openssl
    openssl.dev

    #gnumake
    glib
    pkg-config
    blueberry
    hyprpaper
    hyprcursor
    xorg.xsetroot # to fix cursor in xwayland apps @see https://github.com/hyprwm/Hyprland/issues/7335
    kitty
    libnotify
    mako
    qt5.qtwayland
    qt6.qtwayland
    swayidle
    swaylock-effects
    wlogout
    wl-clipboard
    rofi-wayland
    rofi-calc
    rofimoji
    waybar

    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    xfce.thunar
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    polkit
    lxqt.lxqt-policykit

    gsettings-desktop-schemas
    nwg-look
  ];

  system.stateVersion = "24.05";
}
