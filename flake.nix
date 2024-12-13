{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yandex-browser = {
      url = "github:Teu5us/nix-yandex-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-ld,
      home-manager,
      yandex-browser,
      catppuccin,
    }@inputs:
    let
      host = "nixhome";
      system = "x86_64-linux";
      username = "evgeny";
    in
    {
      nixosConfigurations."${host}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit system inputs host username ;
        };
        modules = [
          nix-ld.nixosModules.nix-ld
          catppuccin.nixosModules.catppuccin
          ./system/configuration.nix
        ];
      };

      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs username;
        };
        modules = [
          catppuccin.homeManagerModules.catppuccin
          ./home
        ];
      };
    };
}
