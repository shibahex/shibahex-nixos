{ ... }:
{
  imports = [
    ./flatpak.nix
    ./packages.nix
    ./programming.nix
    ./audio.nix
    ./ghostty/ghostty.nix
  ];
}
