{ pkgs, ... }:

{

  console = {
    earlySetup = true;
    font = "ter-v16n";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    terminus_font
    noto-fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

}
