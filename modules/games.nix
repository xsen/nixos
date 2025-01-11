{ username, pkgs, ... }:
{

  users.users."${username}".extraGroups = [
    "gamemode"
  ];

  programs = {
    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    steam
    steam-run
    (lutris.override {
      extraPkgs = pkgs: [
        wineWowPackages.stable
        winetricks
      ];
    })
  ];
}
