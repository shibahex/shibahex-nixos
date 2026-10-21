{ pkgs, lib, ... }:
{
  networking.firewall.checkReversePath = "loose";
  networking.firewall.logRefusedPackets = true;
  /*
    47584: for partydeck so steam lan servers work
    11434: AI endpoint port
    80, 443: HTTPs and Web ports
  */
  /*
    47584: PartyDeck (Steam LAN server discovery)
    11434: AI endpoint
    80, 443: HTTP/HTTPS
    27015: ARK Steam query port
    7777: ARK game port
    7778: ARK peer port
    32330: ARK RCON port (TCP only, if enabled)
  */

  networking.firewall.allowedTCPPorts = [
    11434
    47584
    80
    443

    # ARK: Survival Evolved server
    27015 # Steam query
    32330 # RCON
    27020
  ];

  networking.firewall.allowedUDPPorts = [
    47584

    # ARK: Survival Evolved server
    27015 # Steam query
    7777 # Game port
    7778 # Peer port
  ];
}
