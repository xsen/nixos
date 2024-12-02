{ ... }: {
  imports = [
    ./boot.nix
    ./fonts.nix
    ./sound.nix
    ./network.nix
    ./locale.nix
    ./nvidia.nix
    ./users.nix
    ./packages.nix
    ./gui.nix
  ];
}
