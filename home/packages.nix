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
    ./fish.nix
  ];

  programs = {
    spicetify = {
      enable = true;
      wayland = true;
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

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vaapi
      ];
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
    };

    ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 14;
        window-padding-x = 8;
        window-padding-y = 8;
        confirm-close-surface = false;
        cursor-style = "block";
        keybind = [
          "super+ctrl+shift+arrow_down=resize_split:down,10"
          "super+ctrl+shift+arrow_left=resize_split:left,10"
          "super+ctrl+shift+arrow_right=resize_split:right,10"
          "super+ctrl+shift+arrow_up=resize_split:up,10"
          "super+ctrl+shift+KeyJ=write_screen_file:copy"
          "ctrl+alt+shift+KeyJ=write_screen_file:open"
          "super+ctrl+bracket_left=goto_split:previous"
          "super+ctrl+bracket_right=goto_split:next"
          "ctrl+alt+arrow_down=goto_split:down"
          "ctrl+alt+arrow_left=goto_split:left"
          "ctrl+alt+arrow_right=goto_split:right"
          "ctrl+alt+arrow_up=goto_split:up"
          "ctrl+shift+comma=reload_config"
          "ctrl+shift+enter=toggle_split_zoom"
          "ctrl+shift+tab=previous_tab"
          "ctrl+shift+page_down=jump_to_prompt:1"
          "ctrl+shift+page_up=jump_to_prompt:-1"
          "ctrl+shift+arrow_left=previous_tab"
          "ctrl+shift+arrow_right=next_tab"
          "ctrl+shift+KeyA=select_all"
          "ctrl+shift+KeyC=copy_to_clipboard"
          "ctrl+shift+KeyE=new_split:down"
          "ctrl+shift+KeyI=inspector:toggle"
          "ctrl+shift+KeyJ=write_screen_file:paste"
          "ctrl+shift+KeyN=new_window"
          "ctrl+shift+KeyO=new_split:right"
          "ctrl+shift+KeyP=toggle_command_palette"
          "ctrl+shift+KeyQ=quit"
          "ctrl+shift+KeyT=new_tab"
          "ctrl+shift+KeyV=paste_from_clipboard"
          "ctrl+shift+KeyW=close_tab:this"
          "alt+Digit1=goto_tab:1"
          "alt+Digit2=goto_tab:2"
          "alt+Digit3=goto_tab:3"
          "alt+Digit4=goto_tab:4"
          "alt+Digit5=goto_tab:5"
          "alt+Digit6=goto_tab:6"
          "alt+Digit7=goto_tab:7"
          "alt+Digit8=goto_tab:8"
          "alt+Digit9=last_tab"
          "alt+f4=close_window"
          "ctrl+equal=increase_font_size:1"
          "ctrl+plus=increase_font_size:1"
          "ctrl+comma=open_config"
          "ctrl+minus=decrease_font_size:1"
          "ctrl+Digit0=reset_font_size"
          "ctrl+enter=toggle_fullscreen"
          "ctrl+tab=next_tab"
          "ctrl+insert=copy_to_clipboard"
          "ctrl+page_down=next_tab"
          "ctrl+page_up=previous_tab"
          "shift+end=scroll_to_bottom"
          "shift+home=scroll_to_top"
          "shift+insert=paste_from_selection"
          "shift+page_down=scroll_page_down"
          "shift+page_up=scroll_page_up"
          "shift+arrow_down=adjust_selection:down"
          "shift+arrow_left=adjust_selection:left"
          "shift+arrow_right=adjust_selection:right"
          "shift+arrow_up=adjust_selection:up"
          "copy=copy_to_clipboard"
          "paste=paste_from_clipboard"
        ];
      };
    };

    kitty = {
      enable = true;
      shellIntegration = {
        enableZshIntegration = true;
        enableFishIntegration = true;
      };
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
