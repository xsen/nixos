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

}

