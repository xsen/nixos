{ pkgs, username, ... }:
{
  security.polkit = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    polkit
    lxqt.lxqt-policykit
  ];
}
