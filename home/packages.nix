{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{

  imports = [
    ./waybar
    ./rofi.nix
    ./zsh.nix
  ];
  programs = {
    spicetify = {
      enable = true;
      wayland = false;
      windowManagerPatch = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        shuffle
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
    btop = {
      enable = true;
      package = pkgs.btop.override { cudaSupport = true; };
    };
    kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 14;
      };
      settings = {
        confirm_os_window_close = 0;
        window_padding_width = 8;
      };
      shellIntegration.enableZshIntegration = true;
    };
    vim = {
      enable = true;
      settings = {
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        relativenumber = true;
      };
      extraConfig = ''
        set smarttab
        set softtabstop=2
      '';
    };
  };
}
