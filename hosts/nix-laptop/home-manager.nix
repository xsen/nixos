{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
{
  imports = [ ../../home/home.nix ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };

  xdg.configFile."hypr/monitors.lua".text = ''
    hl.monitor({
        output   = "eDP-1",
        mode     = "1920x1080@60",
        position = "0x0",
        scale    = "1",
    })
  '';
}
