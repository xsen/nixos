{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yandex-browser = {
      url = "github:Teu5us/nix-yandex-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    distro-grub-themes = {
      url = "github:AdisonCavani/distro-grub-themes";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      yandex-browser,
      distro-grub-themes,
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
          distro-grub-themes.nixosModules.${system}.default
        ];
      };

      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs.inputs = inputs;
        modules = [ ./home/home.nix ];
      };
    };
}
