{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{

  imports = [
    ./waybar
    ./rofi
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
      shellIntegration.enableZshIntegration = true;

      font = {
        name = "JetBrainsMono Nerd Font";
        size = 14;
      };

      settings = {
        cursor_trail = 3;
        cursor_trail_decay = "0.1 0.4";
        confirm_os_window_close = 0;
        window_padding_width = 8;
      };

      keybindings = {
        "ctrl+c" = "copy_and_clear_or_interrupt";
        "ctrl+v" = "paste_from_clipboard";
        "ctrl+shift+c" = "send_text all \\x03";
      };
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
