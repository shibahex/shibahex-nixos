{ pkgs, ... }:
{
  networking.firewall.checkReversePath = "loose";
  networking.firewall.logRefusedPackets = true;
  /*
    47584: for partydeck so steam lan servers work
    11434: AI endpoint port
    80, 443: HTTPs and Web ports
  */
  networking.firewall.allowedTCPPorts = [
    11434
    47584
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 47584 ];
}
