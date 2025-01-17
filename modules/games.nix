{ username, pkgs, ... }:
{
  users.users."${username}".extraGroups = [
    "gamemode"
  ];

  services.udev.extraRules = ''
    KERNEL=="cpu_dma_latency", GROUP="gamemode"
  '';

  programs.nix-ld.dev.libraries = pkgs.steam-run.args.multiPkgs pkgs;

  programs = {
    gamemode.enable = true;
    gamescope.enable = true;
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
    sessionVariables = {
#      VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    };

    systemPackages = with pkgs; [

      steam
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
