# Nixified & modified version of https://github.com/JaKooLit/Hyprland-Dots/blob/main/config/waybar/configs/%5BTOP%5D%20Default
let scriptPath = "/home/evgeny/Code/nixos/xsen/home/modules/waybar/scripts";
in {
  "hyprland/workspaces" = {
    "active-only" = false;
    "all-outputs" = true;
    "format" = "{icon}";
    "show-special" = false;
    "on-click" = "activate";
    "on-scroll-up" = "hyprctl dispatch workspace e+1";
    "on-scroll-down" = "hyprctl dispatch workspace e-1";
    "persistent-workspaces" = {
      "1" = [];
      "2" = [];
      "3" = [];
      "4" = [];
      "5" = [];
    };
    "format-icons" = {
      "active" = "";
      "default" = "";
    };
  };
  "hyprland/workspaces#pacman" = {
    active-only = false;
    all-outputs = true;
    format = "{icon}";
    on-click = "activate";
    on-scroll-up = "hyprctl dispatch workspace e+1";
    on-scroll-down = "hyprctl dispatch workspace e-1";
    show-special = false;
    persistent-workspaces = {
      "1" = [];
      "2" = [];
      "3" = [];
      "4" = [];
      "5" = [];
    };
    "format-icons" = {
      "active" = " 󰮯 ";
      "default" = "󰊠";
      "persistent" = "󰊠";
    };
  };
  "hyprland/workspaces#4" = {
    "format" = " {name} {icon} ";
    "show-special" = false;
    "on-click" = "activate";
    "on-scroll-up" = "hyprctl dispatch workspace e+1";
    "on-scroll-down" = "hyprctl dispatch workspace e-1";
    "all-outputs" = true;
    "sort-by-number" = true;
    "format-icons" = {
      "1" = " ";
      "2" = " ";
      "3" = " ";
      "4" = " ";
      "5" = " ";
      "6" = " ";
      "7" = "";
      "8" = " ";
      "9" = "";
      "10" = "10";
      "focused" = "";
      "default" = "";
    };
  };
  "clock" = {
    "interval" = 1;
    "format" = " {:%H:%M:%S}";
    "format-alt" = " {:%H:%M   %Y; %d %B; %A}";
    "tooltip-format" = "<tt><small>{calendar}</small></tt>";
    "calendar" = {
      "mode" = "year";
      "mode-mon-col" = 3;
      "weeks-pos" = "right";
      "on-scroll" = 1;
      "format" = {
        "months" = "<span color='#ffead3'><b>{}</b></span>";
        "days" = "<span color='#ecc6d9'><b>{}</b></span>";
        "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
        "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
        "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
      };
    };
  };
  "cpu" = {
    "format" = "{usage}% 󰍛";
    "interval" = 1;
    "format-alt-click" = "click";
    "format-alt" = "{icon0}{icon1}{icon2}{icon3} {usage:>2}% 󰍛";
    "format-icons" = [
      "▁"
      "▂"
      "▃"
      "▄"
      "▅"
      "▆"
      "▇"
      "█"
    ];
    "on-click-right" = "gnome-system-monitor";
  };
  "disk" = {
    "interval" = 30;
    "path" = "/";
    "format" = "{percentage_used}% 󰋊";
    "tooltip-format" = "{used} used out of {total} on {path} ({percentage_used}%)";
  };
  "memory" = {
    "interval" = 10;
    "format" = "{used:0.1f}G 󰾆";
    "format-alt" = "{percentage}% 󰾆";
    "format-alt-click" = "click";
    "tooltip" = true;
    "tooltip-format" = "{used:0.1f}GB/{total:0.1f}G";
    "on-click-right" = "kitty --title btop sh -c 'btop'";
  };
  "mpris" = {
    "interval" = 10;
    "format" = "{player_icon} ";
    "format-paused" = "{status_icon} <i>{dynamic}</i>";
    "on-click-middle" = "playerctl play-pause";
    "on-click" = "playerctl previous";
    "on-click-right" = "playerctl next";
    "scroll-step" = 5.0;
    "on-scroll-up" = "${scriptPath}/volume.sh --inc";
    "on-scroll-down" = "${scriptPath}/volume.sh --dec";
    "smooth-scrolling-threshold" = 1;
    "player-icons" = {
      "chromium" = "";
      "vivaldi" = "";
      "default" = "";
      "firefox" = "";
      "kdeconnect" = "";
      "mopidy" = "";
      "mpv" = "󰐹";
      "spotify" = "";
      "vlc" = "󰕼";
    };
    "status-icons" = {
      "paused" = "󰐎";
      "playing" = "";
      "stopped" = "";
    };
    "max-length" = 30;
  };
  "network" = {
      "format" = "{ifname}";
      "format-wifi" = "{icon}";
      "format-ethernet" = "󰌘";
      "format-disconnected" = "󰌙";
      "tooltip-format" = "{ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
      "format-linked" = "󰈁 {ifname} (No IP)";
      "tooltip-format-wifi" = "{essid} {icon} {signalStrength}%";
      "tooltip-format-ethernet" = "{ifname} 󰌘";
      "tooltip-format-disconnected" = "󰌙 Disconnected";
      "max-length" = 50;
      "format-icons" = [
          "󰤯"
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
      ];
  };
  "network#speed" = {
      "interval" = 1;
      "format" = "{ifname}";
      "format-wifi" = "{icon}  {bandwidthUpBytes}  {bandwidthDownBytes}";
      "format-ethernet" = "󰌘   {bandwidthUpBytes}  {bandwidthDownBytes}";
      "format-disconnected" = "󰌙";
      "tooltip-format" = "{ipaddr}";
      "format-linked" = "󰈁 {ifname} (No IP)";
      "tooltip-format-wifi" = "{essid} {icon} {signalStrength}%";
      "tooltip-format-ethernet" = "{ifname} 󰌘";
      "tooltip-format-disconnected" = "󰌙 Disconnected";
      "max-length" = 50;
      "format-icons" = [
          "󰤯"
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
      ];
  };
  "pulseaudio" = {
      "format" = "{icon} {volume}%";
      "format-muted" = "󰖁";
      "format-icons" = {
          "headphone" = "";
          "hands-free" = "";
          "headset" = "";
          "phone" = "";
          "portable" = "";
          "car" = "";
          "default" = [
            ""
            ""
            "󰕾"
            ""
          ];
          "ignored-sinks" = [
            "Easy Effects Sink"
          ];
      };
      "scroll-step" = 5.0;
      "on-click" = "${scriptPath}/volume.sh --toggle";
      "on-click-right" = "pavucontrol -t 3";
      "on-scroll-up" = "${scriptPath}/volume.sh --inc";
      "on-scroll-down" = "${scriptPath}/volume.sh --dec";
      "tooltip-format" = "{icon} {desc} | {volume}%";
      "smooth-scrolling-threshold" = 1;
  };
  "pulseaudio#microphone" = {
      "format" = "{format_source}";
      "format-source" = " {volume}%";
      "format-source-muted" = "";
      "on-click" = "${scriptPath}/volume.sh --toggle-mic";
      "on-click-right" = "pavucontrol -t 4";
      "on-scroll-up" = "${scriptPath}/volume.sh --mic-inc";
      "on-scroll-down" = "${scriptPath}/volume.sh --mic-dec";
      "tooltip-format" = "{source_desc} | {source_volume}%";
      "scroll-step" = 5;
  };
  "temperature" = {
      "interval" = 10;
      "tooltip" = true;
      "hwmon-path" = [
        "/sys/class/hwmon/hwmon1/temp1_input"
        "/sys/class/thermal/thermal_zone0/temp"
      ];
      "critical-threshold" = 82;
      "format-critical" = "{temperatureC}°C {icon}";
      "format" = "{temperatureC}°C {icon}";
      "format-icons" = [
        "󰈸"
      ];
      "on-click-right" = "wezterm -e nvtop sh -c 'nvtop'";
  };
  "tray" = {
    "icon-size" = 15;
    "spacing" = 8;
  };
  "custom/menu" = {
    "format" = " ";
    "tooltip" = true;
    "on-click" = "pkill rofi || rofi -show drun -modi run;drun;calc;filebrowser;window";
    #"on-click-middle" = "${scriptPath}/wallpaper.sh";
  };
  "custom/cava_mviz" = {
    "exec" = "${scriptPath}/cava.sh";
    "format" = "{}";
  };
  "custom/swaync" = {
    "tooltip" = true;
    "format" = "{icon} {}";
    "format-icons" = {
      "notification" = "<span foreground='red'><sup></sup></span>";
      "none" = "";
      "dnd-notification" = "<span foreground='red'><sup></sup></span>";
      "dnd-none" = "";
      "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
      "inhibited-none" = "";
      "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
      "dnd-inhibited-none" = "";
    };
    "return-type" = "json";
    "exec-if" = "which swaync-client";
    "exec" = "swaync-client -swb";
    "on-click" = "sleep 0.1 && swaync-client -t -sw";
    "on-click-right" = "swaync-client -d -sw";
    "escape" = true;
  };
  "custom/separator#dot" = {
    "format" = "";
    "interval" = "once";
    "tooltip" = false;
  };
  "custom/separator#dot-line" = {
    "format" = "";
    "interval" = "once";
    "tooltip" = false;
  };
  "custom/separator#line" = {
    "format" = "|";
    "interval" = "once";
    "tooltip" = false;
  };
  "custom/separator#blank" = {
    "format" = "";
    "interval" = "once";
    "tooltip" = false;
  };
  "custom/separator#blank_2" = {
    "format" = "  ";
    "interval" = "once";
    "tooltip" = false;
  };
  "custom/separator#blank_3" = {
    "format" = "   ";
    "interval" = "once";
    "tooltip" = false;
  };
}
