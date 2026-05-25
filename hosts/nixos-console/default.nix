{ ... }:
{
  imports = [
    ./hardware.nix
    ./host-packages.nix
    ./services
  ];
  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "git+https://github.com/shibahex/nixos-config#nixos-console";
}
