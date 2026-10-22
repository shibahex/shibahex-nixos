{ ... }:
{
  imports = [
    ./hardware.nix
    ./variables.nix
    ./host-packages.nix
    ./xserver_vm.nix
  ];
}
