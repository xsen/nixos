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
    ../../modules/core.nix
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        configurationLimit = 3;

        gfxmodeEfi = "3440x1440x32";
        extraConfig = "set gfxpayload=keep";
      };
    };

    blacklistedKernelModules = [ "nouveau" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "video=3440x1440"
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_EnableGpuFirmware=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia-drm.modeset=1"
    ];
    initrd.kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_uvm"
      "nvidia_modeset"
    ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-vdpau-driver
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

      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "595.91.07";
        sha256_64bit = "sha256-yiPIjdJLB6GRZE4eEc+3vN11NzBXSa9A+YABiwleYxM=";
        sha256_aarch64 = "sha256-fqkN7ONFXtTeXyu2mQxorrk362Epxq3bz88hhKYQzwQ=";

        openSha256 = "sha256-OB8Epd+qn/WywxsPiFpxEOAzlJqb6I1SyRoV3a8l71k=";
        settingsSha256 = "sha256-QzT8Cw1luuZGP9DUje3HN/0ngiayqHURj+bqPsxlJ5w=";
        persistencedSha256 = "sha256-3JQBaNmkwxvCXv9q8aHKas6VZM/JjLsuilC2t7ET0u0=";
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  system.stateVersion = "24.05";
}
