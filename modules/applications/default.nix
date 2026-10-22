{ ... }:
{
  imports = [
    ./flatpak.nix
    ./packages.nix
    ./programming.nix
    ./audio.nix
    ./gaming.nix
    ./ghostty/ghostty.nix
  ];
}
