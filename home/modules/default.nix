{
  imports = [
    ./config.nix
    ./environment.nix
    ./git.nix
    ./gtk.nix
    ./packages.nix
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
