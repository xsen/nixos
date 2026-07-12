{
  description = "Не надо дядя";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    antigravity-cli.url = "github:xsen/antigravity-cli-nix";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-ld,
      nixpkgs,
      antigravity-cli,
      nixpkgs-master,
      catppuccin,
      home-manager,
      spicetify-nix,
      yandex-browser,
      nix-index-database,
    }@inputs:
    let
      system = "x86_64-linux";
      username = "evgeny";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
        };
        overlays = [
          (import ./overlays.nix { inherit inputs; })
        ];
      };
    in
    {
      nixosConfigurations."nix-desktop" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            username
            ;
          host = "nix-desktop";
        };
        modules = [
          home-manager.nixosModules.home-manager
          catppuccin.nixosModules.catppuccin
          ./hosts/nix-desktop/configuration.nix
          {
            nixpkgs.pkgs = pkgs;
          }
        ];
      };

      nixosConfigurations."nix-laptop" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            username
            ;
          host = "nix-laptop";
        };
        modules = [
          home-manager.nixosModules.home-manager
          catppuccin.nixosModules.catppuccin
          ./hosts/nix-laptop/configuration.nix
          {
            nixpkgs.pkgs = pkgs;
          }
        ];
      };

      homeConfigurations."${username}@nix-desktop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit
            inputs
            username
            ;
          host = "nix-desktop";
        };
        modules = [
          catppuccin.homeModules.catppuccin
          spicetify-nix.homeManagerModules.spicetify
          nix-index-database.homeModules.nix-index
          ./hosts/nix-desktop/home-manager.nix
        ];
      };

      homeConfigurations."${username}@nix-laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit
            inputs
            username
            ;
          host = "nix-laptop";
        };
        modules = [
          catppuccin.homeModules.catppuccin
          spicetify-nix.homeManagerModules.spicetify
          nix-index-database.homeModules.nix-index
          ./hosts/nix-laptop/home-manager.nix
        ];
      };
    };
}
