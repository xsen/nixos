{ pkgs,... }: {

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.evgeny = {
    isNormalUser = true;
    description = "Evgeny";
    extraGroups = [ "networkmanager" "wheel" ];

    packages = with pkgs; [

    ];
  };

}
