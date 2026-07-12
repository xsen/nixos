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
    ../../modules/packages.nix
    ../../modules/core.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    fprintd.enable = true;
  };

  security.pam.services = {
    sudo.fprintAuth = true;
    login.fprintAuth = true;
  };

  system.stateVersion = "24.11";
}
