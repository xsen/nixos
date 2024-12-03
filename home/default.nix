{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
{
  imports = [ ./modules ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /home/evgeny/nixos/";
    };
  };
}
