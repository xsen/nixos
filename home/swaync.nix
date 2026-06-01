{ config, lib, pkgs, ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2way-close = true;
      notification-drop-shadow = false;
      label-position = "bottom";
      control-center-width = 500;
      control-center-height = 600;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-length = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      scripts = {
        example-script = {
          exec = "${pkgs.writeShellScript "swaync-play-sound" ''
            if [ "$(${config.services.swaync.package}/bin/swaync-client -D)" != "true" ]; then
              ${pkgs.pulseaudio}/bin/paplay ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga
            fi
          ''}";
          run-on = "receive";
        };
      };
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        label = {
          max-lines = 1;
          text = "Notification Center";
        };
        mpris = {
          image-size = 96;
          image-radius = 12;
        };
      };
      widgets = [
        "dnd"
        "title"
        "mpris"
        "notifications"
      ];
    };
  };

  systemd.user.services.swaync.Service.ExecStart = lib.mkForce "${config.services.swaync.package}/bin/swaync -s %h/.config/swaync/custom.css";

  home.file.".config/swaync/custom.css".text = ''
    @import "style.css";

    /* Отступы для виджетов в SwayNC */
    .widget-title {
      margin-top: 10px;
      margin-bottom: 15px;
    }
    .widget-dnd {
      margin-bottom: 15px;
    }
    .widget-mpris {
      margin-top: 10px;
      margin-bottom: 10px;
    }
  '';
}
