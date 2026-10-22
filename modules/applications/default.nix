{ ... }:
{
  imports = [
    ./flatpak.nix
    ./packages.nix
    ./programming.nix
    ./audio.nix
    ./file-manager.nix
    ./gaming.nix
    ./recording.nix
    ./ghostty/ghostty.nix
  ];
}
