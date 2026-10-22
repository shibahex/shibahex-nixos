{ ... }:
{
  imports = [
    ./boot.nix
    ./home-manager.nix
    ./fonts.nix
    ./services.nix
    ./nix-system.nix
    ./network.nix
    ./virtualisation.nix
    ./docker.nix
    ./performance.nix
  ];
}
