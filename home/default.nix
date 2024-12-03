{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ ./modules ];

  home = {
    username = "evgeny";
    homeDirectory = "/home/evgeny";
    stateVersion = "24.11";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /home/evgeny/nixos/";
    };
  };
}
