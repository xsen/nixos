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

}
