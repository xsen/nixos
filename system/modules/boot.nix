{ ... }:
{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
  };

  distro-grub-themes = {
    enable = true;
    theme = "nixos";
  };
}
