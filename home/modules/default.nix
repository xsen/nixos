{
  imports = [
    ./gui.nix
    ./packagex.nix
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
