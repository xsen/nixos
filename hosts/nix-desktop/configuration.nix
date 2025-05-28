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
    ../../modules/dev.nix
    ../../modules/games.nix
    ../../modules/packages.nix
  ];

  nix = {
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

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;

        gfxmodeEfi = "3440x1440x32";
        extraConfig = "set gfxpayload=keep";
      };
    };

    blacklistedKernelModules = [ "nouveau" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "video=3440x1440@144"
      "nvidia.NVreg_EnableGpuFirmware=0"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia-drm.modeset=1"
    ];
    initrd.kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_uvm"
    ];
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

      #package = config.boot.kernelPackages.nvidiaPackages.latest;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "570.153.02";
        sha256_64bit = "sha256-FIiG5PaVdvqPpnFA5uXdblH5Cy7HSmXxp6czTfpd4bY=";
        sha256_aarch64 = "sha256-FIiG5PaVdvqPpnFA5uXdblH5Cy7HSmXxp6czTfpd4bY=";
        openSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        persistencedSha256 = lib.fakeSha256;
      };
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
        enableHidpi = true;
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

    syncthing = {
      enable = true;
      user = username;
      dataDir = "/home/${username}/Cloud/Syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        folders = {
          "Books" = {
            path = "/home/${username}/Cloud/Syncthing/Books";
          };
        };
      };
    };
  };

  security = {
    rtkit.enable = true;
    wrappers = {
      nekobox_core = {
        source = "${pkgs.nekoray.passthru.nekobox-core}/bin/nekobox_core";
        owner = "root";
        group = "root";
        setuid = true;
      };
    };
  };
  systemd.services.sddm-wallpaper = {
    description = "Update SDDM wallpaper";
    script = ''
      mkdir -p /background
      chmod 755 /background
      if [ -f "/home/${username}/.wallpapers/current.png" ]; then
        cp -f "/home/${username}/.wallpapers/current.png" "/background/current.png"
      else
        echo "Warning: Source wallpaper not found!" >&2
      fi
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "display-manager.service" ];
  };

  networking = {
    hostName = host;

    nftables.enable = true;
    networkmanager.enable = true;

    firewall = {
      enable = true;
      checkReversePath = false;
      allowedTCPPorts = [
        9003
        8384
        22000
      ];
      allowedUDPPorts = [
        22000
        21027
      ];

      trustedInterfaces = [
        "br-*"
      ];
    };
  };

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
    terminus_font
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";

    sddm = {
      fontSize = "20";
      background = "/background/current.png";
      font = "JetBrainsMono Nerd Font";
    };
  };

  environment = {
    variables = {
      EDITOR = "vim";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  system.stateVersion = "24.05";
}
