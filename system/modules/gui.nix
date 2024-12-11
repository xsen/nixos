{
  config,
  pkgs,
  lib,
  ...
}:

{
  catppuccin.flavor = "macchiato";
  catppuccin.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = { };
  security.pam.services.swaylock.fprintAuth = false;

  services = {
    dbus.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    xdgOpenUsePortal = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  programs = {
    hyprland = {
      enable = true;

      xwayland = {
        enable = true;
      };

      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };

  environment.systemPackages = with pkgs; [
    hyprpaper
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
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr

    polkit
    lxqt.lxqt-policykit

    gsettings-desktop-schemas
    nwg-look
  ];
}
