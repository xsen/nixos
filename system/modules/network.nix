{ ... }:
{

  networking = {
    hostName = "nixhome";

    nftables.enable = true;
    networkmanager.enable = true;

    firewall = {
      enable = true;
      checkReversePath = false;
    };
  };
}
