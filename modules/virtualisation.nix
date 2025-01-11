{ username, pkgs, ... }:
{

  users.users."${username}".extraGroups = [
    "docker"
  ];

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
