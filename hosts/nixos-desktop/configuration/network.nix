{ self, ... }:
{

  /*
    48000, 48010: moonlight
    47584: partydeck for steam splitscreen
  */
  networking.firewall.allowedUDPPorts = [
    47584
    48000
    48010
  ];
  networking.firewall.allowedTCPPorts = [
    47584
    48010
  ];

  security.pki.certificateFiles = [
    "${self}/certs/step-root-ca.crt"
  ];
  environment.variables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_DIR = "/etc/ssl/certs/";
  };
}
