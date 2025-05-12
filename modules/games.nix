{ username, pkgs, ... }:
{
  users.users."${username}".extraGroups = [
    "gamemode"
  ];

  programs.nix-ld.dev.libraries = pkgs.steam-run.args.multiPkgs pkgs;

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

    security.pam.loginLimits = [
      {
        domain = "@gamemode";
        type = "-";
        item = "rtprio";
        value = 98;
      }
      {
        domain = "@gamemode";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@gamemode";
        type = "-";
        item = "nice";
        value = -20;
      }
    ];

  environment = {
    systemPackages = with pkgs; [
      steam-run
      vulkan-tools

      wineWowPackages.stable
      winetricks

      (lutris.override {
        extraPkgs = pkgs: [
          wineWowPackages.stable
          winetricks
          gamemode
          gamescope
        ];
      })
    ];
  };
}
