{ pkgs, ... }:

{
  networking.extraHosts = ''
    10.1.0.236 ai-agent.adams.internal
  '';
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."ai-agent.adams.internal" = {
      # This single block handles everything:
      # 1. Binds ports 80 and 443
      # 2. Redirects HTTP to HTTPS
      # 3. Uses the self-signed cert generated above
      forceSSL = true;
      sslCertificate = "/var/lib/ai-certs/ai-serv.crt";
      sslCertificateKey = "/var/lib/ai-certs/ai-serv.key";

      locations."/" = {
        proxyPass = "http://127.0.0.1:11434";
        extraConfig = ''
          allow 10.1.0.0/16;
          deny all;

          proxy_buffering off;
          proxy_request_buffering off;
          proxy_cache off;

          proxy_read_timeout 300s;
          proxy_connect_timeout 300s;
          proxy_send_timeout 300s;
        '';
      };
      # For the embedding model (for open webUI search feature)
      locations."/embeddings/" = {
        proxyPass = "http://127.0.0.1:11435/";
        extraConfig = ''
          allow 10.1.0.0/16;
          deny all;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_cache off;
          proxy_read_timeout 300s;
          proxy_connect_timeout 300s;
          proxy_send_timeout 300s;
        '';
      };
    };
  };
}
