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
}
