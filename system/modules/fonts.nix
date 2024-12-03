{ pkgs, ... }:

{
  console = {
    font = "cyr-sun16";
    useXkbConfig = true;
  };

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    noto-fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono"]; })
  ];

}
