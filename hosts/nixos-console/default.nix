{ ... }:
{
  imports = [
    ./hardware.nix
    ./variables.nix
    ./host-packages.nix
    ./services
    ./configuration
  ];
}
