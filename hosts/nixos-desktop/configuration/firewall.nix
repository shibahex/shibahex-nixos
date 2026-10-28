{ pkgs, lib, ... }:
{
  /*
     8765: AnkiConnect (for the health dashboard)
  */
  networking.firewall.allowedTCPPorts = [
    8765
  ];

  networking.firewall.allowedUDPPorts = [
  ];
}



