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

    vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };

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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
        window-padding-x = 14;
        window-padding-y = 14;
        confirm-close-surface = false;
        cursor-style = "block";
        scrollbar = "never";
        keybind = [
          # Tabs (Alt)
          "alt+n=new_tab"
          "alt+w=close_tab:this"
          "alt+h=previous_tab"
          "alt+l=next_tab"
          "alt+Digit1=goto_tab:1"
          "alt+Digit2=goto_tab:2"
          "alt+Digit3=goto_tab:3"
          "alt+Digit4=goto_tab:4"
          "alt+Digit5=goto_tab:5"
          "alt+Digit6=goto_tab:6"
          "alt+Digit7=goto_tab:7"
          "alt+Digit8=goto_tab:8"
          "alt+Digit9=last_tab"

          # Splits Navigation (Alt+Shift + HJKL)
          "alt+shift+h=goto_split:left"
          "alt+shift+j=goto_split:down"
          "alt+shift+k=goto_split:up"
          "alt+shift+l=goto_split:right"

          # Splits Actions
          "alt+shift+v=new_split:right"
          "alt+shift+s=new_split:down"
          "alt+shift+w=close_surface"
          "alt+shift+m=toggle_split_zoom"
          "ctrl+shift+enter=toggle_split_zoom"
          "alt+shift+equal=equalize_splits"

          # Splits Resize
          "ctrl+shift+alt+h=resize_split:left,20"
          "ctrl+shift+alt+j=resize_split:down,20"
          "ctrl+shift+alt+k=resize_split:up,20"
          "ctrl+shift+alt+l=resize_split:right,20"
          "super+ctrl+shift+arrow_down=resize_split:down,10"
          "super+ctrl+shift+arrow_left=resize_split:left,10"
          "super+ctrl+shift+arrow_right=resize_split:right,10"
          "super+ctrl+shift+arrow_up=resize_split:up,10"

          # System & Clipboard
          "ctrl+shift+comma=reload_config"
          "ctrl+comma=open_config"
          "ctrl+shift+KeyC=copy_to_clipboard"
          "ctrl+shift+KeyV=paste_from_clipboard"
          "ctrl+shift+KeyA=select_all"
          "ctrl+shift+KeyN=new_window"
          "ctrl+shift+KeyP=toggle_command_palette"
          "ctrl+shift+KeyI=inspector:toggle"
          "ctrl+shift+KeyQ=quit"
          "ctrl+shift+page_down=jump_to_prompt:1"
          "ctrl+shift+page_up=jump_to_prompt:-1"
          "super+ctrl+shift+KeyJ=write_screen_file:copy"
          "ctrl+alt+shift+KeyJ=write_screen_file:open"
          "ctrl+shift+KeyJ=write_screen_file:paste"
          "alt+f4=close_window"
          "ctrl+equal=increase_font_size:1"
          "ctrl+plus=increase_font_size:1"
          "ctrl+minus=decrease_font_size:1"
          "ctrl+Digit0=reset_font_size"
          "ctrl+enter=toggle_fullscreen"
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

    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    nix-index-database.comma.enable = true;
  };
}
