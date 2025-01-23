{ username, pkgs, ... }:
{

  users.users."${username}".extraGroups = [
    "docker"
  ];

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    glib
    pkg-config
    openssl
    openssl.dev

    neovim
    jetbrains-toolbox
    jetbrains.jdk
    code-cursor
    vscode
  ];
}
