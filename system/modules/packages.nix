{ config, inputs, pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    git
    vim 
  ];

}
