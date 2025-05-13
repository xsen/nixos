{
  description = "Не надо дядя";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix/main";
    #    yandex-music.url = "github:cucumber-sp/yandex-music-linux";
    yandex-browser.url = "github:miuirussia/yandex-browser.nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
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
      nix-ld,
      nixpkgs,
      catppuccin,
      home-manager,
      #      yandex-music,
      yandex-browser,
    }@inputs:
    let
      host = "nix-desktop";
      system = "x86_64-linux";
      username = "evgeny";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "SDL_ttf-2.0.11" ];
        };
        overlays = [
         (import ./overlays.nix { inherit inputs; })
        ];
      };
    in
    {
      nixosConfigurations."${host}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            system
            inputs
            host
            username
            ;
        };
        modules = [
          nix-ld.nixosModules.nix-ld
          home-manager.nixosModules.home-manager
          catppuccin.nixosModules.catppuccin
          ./hosts/${host}/configuration.nix
          {
            nixpkgs.pkgs = pkgs;
          }
        ];
      };

      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit
            system
            inputs
            host
            username
            ;
        };
        modules = [
          catppuccin.homeModules.catppuccin
          ./hosts/${host}/home-manager.nix
          #          yandex-music.homeManagerModules.default
        ];
      };
    };
}
