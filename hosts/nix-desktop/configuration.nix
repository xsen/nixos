{
  lib,
  username,
  host,
  pkgs,
  inputs,
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/polkit.nix
    ../../modules/nix-ld.nix
    ../../modules/virtualisation.nix
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

    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"
    ];
    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  };

  hardware = {
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
        vdpauinfo
        libva
        libva-utils
      ];
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      forceFullCompositionPipeline = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;
#      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
#        version = "550.142";
#        sha256_64bit = "sha256-bdVJivBLQtlSU7Zre9oVCeAbAk0s10WYPU3Sn+sXkqE=";
#        sha256_aarch64 = "sha256-bdVJivBLQtlSU7Zre9oVCeAbAk0s10WYPU3Sn+sXkqE=";
#        openSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
#        settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
#        persistencedSha256 = lib.fakeSha256;
#      };
    };
  };

  services = {
    flatpak.enable = true;
    pulseaudio.enable = false;
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

  security = {
    rtkit.enable = true;
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
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
      "docker"
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
    terminus_font
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];

  programs = {
    zsh.enable = true;

    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      withUWSM = true;
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
    yazi
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
    xorg.xsetroot # to fix cursor in xwayland apps @see https://github.com/hyprwm/Hyprland/issues/7335
    kitty
    libnotify
    qt5.qtwayland
    qt6.full
    qt6.qtwayland
    polkit
    lxqt.lxqt-policykit

    wl-clipboard
    xfce.thunar
  ];
  system.stateVersion = "24.05";
}
