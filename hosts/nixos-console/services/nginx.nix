{ pkgs, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "badamsva@gmail.com";
  };

  services.ollama = {
    enable = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."ollama.example.com" = {
      enableACME = true; # request cert from Let's Encrypt
      forceSSL = true; # redirect http -> https

      locations."/" = {
        proxyPass = "http://127.0.0.1:11434";
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 300s;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
