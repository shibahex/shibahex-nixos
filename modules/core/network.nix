{ pkgs
, host
, options
, ...
}:
# let inherit (import ../../hosts/${host}/variables.nix) hostId;
# in
{
  networking = {
    hostName = "${host}";
    # hostId = hostId;
    networkmanager.enable = true;
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    firewall = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
