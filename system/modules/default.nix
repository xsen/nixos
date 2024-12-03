{ ... }:
{
  imports = [
    ./boot.nix
    ./locale.nix
    ./fonts.nix
    ./sound.nix
    ./network.nix
    ./nvidia.nix
    ./users.nix
    ./packages.nix
    ./gui.nix
  ];
}
