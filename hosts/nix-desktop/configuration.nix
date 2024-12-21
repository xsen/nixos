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

    initrd.kernelModules = [ "nvidia" "nvidia_drm" ];
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  };


  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false;

    graphics = {
      enable = true;
      enable32Bit = true;
         extraPackages = with pkgs; [
           nvidia-vaapi-driver
           libvdpau-va-gl
         ];
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  services = {
    flatpak.enable = true;
    journald.extraConfig = "SystemMaxUse=1G";

    displayManager = {
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
    LIBVA_DRIVER_NAME = "nvidia";
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
  catppuccin.flavor = "mocha";

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
      #pkgs.xdg-desktop-portal-gtk
    ];
  };

  programs = {
    zsh.enable = true;

    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      withUWSM = true;
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
    eza
    fzf
    bat
    lm_sensors
    ripgrep
    tldr
    unzip
    openssl
    openssl.dev
    glib
    pkg-config
    blueberry
    hyprcursor
    xorg.xsetroot # to fix cursor in xwayland apps @see https://github.com/hyprwm/Hyprland/issues/7335
    kitty
    libnotify
    qt5.qtwayland
    qt6.qtwayland

    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit
    lxqt.lxqt-policykit

    hyprpaper
    swayidle
    swaylock-effects
    wlogout
    wl-clipboard
    waybar
    xfce.thunar

    gsettings-desktop-schemas
    nwg-look
  ];

  system.stateVersion = "24.05";
}
