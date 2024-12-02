{ pkgs, username, ... }:
{

  users.users."${username}" = {
    isNormalUser = true;
    description = "Evgeny";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    packages = with pkgs; [

    ];
  };

}
