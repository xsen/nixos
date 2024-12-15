{
  layer = "top";
  exclusive = true;
  passthrough = false;
  position = "top";
  spacing = 3;
  fixed-center = true;
  ipc = true;
  margin-top = 3;
  margin-left = 8;
  margin-right = 8;
  modules-left = [
    "hyprland/workspaces#pacman"
    "custom/separator#dot-line"
    "cpu"
    "custom/separator#dot-line"
    "temperature"
    "custom/separator#dot-line"
    "memory"
    "custom/separator#dot-line"
    "hyprland/language"
  ];
  modules-center = [
    "clock"
    "custom/separator#dot-line"
    "custom/menu"
    "custom/separator#dot-line"
    "custom/cava_mviz"
  ];
  modules-right = [
    "network#speed"
    "custom/separator#dot-line"
    "custom/swaync"
    "tray"
    "mpris"
    "custom/separator#dot-line"
    "pulseaudio"
    "custom/separator#dot-line"
    "pulseaudio#microphone"
  ];
}
