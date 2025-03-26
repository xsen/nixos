{
  description = "Не надо дядя";

  inputs = {
    nixgl.url = "github:nix-community/nixGL";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    yandex-music.url = "github:cucumber-sp/yandex-music-linux";
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
      nixgl,
      nix-ld,
      nixpkgs,
      catppuccin,
      home-manager,
      yandex-music,
      yandex-browser,
    }@inputs:
    let
      host = "nix-desktop";
      system = "x86_64-linux";
      username = "evgeny";

      pkgsConfig = {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          inputs.nixgl.overlay
          (final: prev: {
            yandex-browser-stable = inputs.yandex-browser.packages.${prev.system}.yandex-browser-stable;
          })
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
          { nixpkgs.pkgs = import nixpkgs pkgsConfig; }
          nix-ld.nixosModules.nix-ld
          catppuccin.nixosModules.catppuccin
          ./hosts/${host}/configuration.nix
        ];
      };

      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs pkgsConfig;
        extraSpecialArgs = {
          inherit
            system
            inputs
            host
            username
            ;
        };
        modules = [
          catppuccin.homeManagerModules.catppuccin
          ./hosts/${host}/home-manager.nix
          yandex-music.homeManagerModules.default
        ];
      };
    };
}
