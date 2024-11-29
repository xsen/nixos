{
    imports = [
	./git.nix
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
