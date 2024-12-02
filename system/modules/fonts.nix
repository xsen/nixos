{ pkgs, ... }:

{
  console = {
    earlySetup = true;
    font = "cyr-sun16";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono

    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

}
