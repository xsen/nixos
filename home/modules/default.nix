{
  imports = [
    ./gui.nix
    ./env.nix
    ./dotfiles.nix
    ./packages.nix
    ./waybar
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);

      permittedInsecurePackages = [
        #"electron-25.9.0" # Obsidian
      ];
    };
  };
}
