let
  configDir = ../config;
in
{
  home.file = {
    ".ideavimrc".source = "${configDir}/ideavimrc";
    ".config/hypr".source = "${configDir}/hypr";
    ".config/.oh-my-zsh" = {
      recursive = true;
      source = "${configDir}/catppuccin-zsh/";
    };
  };
}
