{
  description = "Не надо дядя";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
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
      host = "nix-desktop";
      system = "x86_64-linux";
      username = "evgeny";
    in
    {
      nixosConfigurations."${host}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit system inputs host username;
        };
        modules = [
          nix-ld.nixosModules.nix-ld
          catppuccin.nixosModules.catppuccin
          ./hosts/${host}/configuration.nix
        ];
      };

      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit system inputs host username;
        };
        modules = [
          catppuccin.homeManagerModules.catppuccin
          ./hosts/${host}/home.nix
        ];
      };
    };
}
