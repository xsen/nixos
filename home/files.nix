{ config, ... }:
let
  nixConfigDir = "${config.home.homeDirectory}/Code/nixos/xsen";
in
{
  home.file = {
    ".npmrc".source = ./npmrc;

    # Out-of-store symlinks for mutable configuration files (accessible for agents/user without rebuilding)
    ".config/zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/zed/settings.json";
    ".config/zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/zed/keymap.json";
    ".config/zed/tasks.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/zed/tasks.json";

    ".gemini/config/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/AGENTS.md";
    ".gemini/config/mcp_config.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/mcp_config.json";
    ".gemini/config/instructions.md".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/instructions.md";
    ".gemini/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/settings.json";
    ".gemini/antigravity-cli/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/cli-settings.json";
    ".gemini/antigravity-cli/statusline-command.sh".source = config.lib.file.mkOutOfStoreSymlink "${nixConfigDir}/home/antigravity/statusline-command.sh";

    ".scripts/smart-screenshot.sh" = {
      source = ./scripts/smart-screenshot.sh;
      executable = true;
    };
    ".scripts/switch-layout" = {
      source = ./scripts/switch-layout.sh;
      executable = true;
    };
    ".scripts/launch-apps" = {
      source = ./scripts/launch-apps.sh;
      executable = true;
    };
    ".scripts/change-wallpaper" = {
      source = ./scripts/change-wallpaper.sh;
      executable = true;
    };

    ".local/share/icons/start-apps-icon.png".source = ./images/start-apps-icon.png;
    ".local/share/applications/launch-apps.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Launch Apps
      Comment=Launches common applications
      Icon=${config.home.homeDirectory}/.local/share/icons/start-apps-icon.png
      Exec=${config.home.homeDirectory}/.scripts/launch-apps
      StartupNotify=false
    '';
  };
}
