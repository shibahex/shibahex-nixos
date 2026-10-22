{
  pkgs,
  lib,
  host,
  options,
  ...
}:
{
  networking = {
    hostName = lib.mkDefault host;
    networkmanager.enable = lib.mkDefault true;
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    firewall.enable = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
