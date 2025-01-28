{
  layer = "top";
  position = "right";
  fixed-center = true;
  reload_style_on_change = true;
  margin = "4px, 4px, 4px, 4px";
  modules-left = [
    "custom/separator#hr"
    "custom/gpu"
    "custom/separator#hr"
    "cpu"
    "custom/separator#hr"
    "temperature"
    "custom/separator#hr"
    #    "network#speed"
    "memory"
    "custom/separator#hr"
    "disk"
    "custom/separator#hr"
  ];
  modules-center = [
    #    "mpris"
#    "hyprland/window"
    "custom/separator#hr"
    "hyprland/workspaces#pacman"
    "custom/separator#hr"
    "hyprland/language"
    "custom/separator#hr"
    #    "custom/separator#dot-line"
    #    "custom/menu"
    #    "custom/separator#dot-line"
    #    "custom/cava_mviz"
  ];
  modules-right = [
    "custom/separator#hr"
    #"custom/swaync"
    "tray"
    "custom/separator#hr"
    "pulseaudio"
    "custom/separator#hr"
    "pulseaudio#microphone"
    "custom/separator#hr"
    "clock"
    "custom/separator#hr"
  ];
}
