{
  description = "A very basic flake";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yandex-browser = {
      url = "github:Teu5us/nix-yandex-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      yandex-browser,
      catppuccin,
    }@inputs:
    let

      system = "x86_64-linux";
      host = "nixhome";
      username = "evgeny";

    in
    {
      nixosConfigurations.nixhome = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit
            system
            inputs
            host
            username
            ;
        };
        modules = [
          ./system/configuration.nix
          catppuccin.nixosModules.catppuccin
        ];
      };

      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs.inputs = inputs;
        extraSpecialArgs.username = username;
        modules = [
          ./home
          catppuccin.homeManagerModules.catppuccin
        ];
      };
    };
}
