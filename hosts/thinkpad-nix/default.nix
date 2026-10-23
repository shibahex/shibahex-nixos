{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./variables.nix
    ./host-packages.nix
    ./battery.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [
      22
      80
      443
      59010
      59011
      8080
    ];
    allowedUDPPorts = [
      59010
      59011
    ];
  };
}
