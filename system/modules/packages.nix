{ config, inputs, pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    home-manager
    pciutils
    nixfmt-rfc-style
    wget
    git
    vim 
  ];

}
