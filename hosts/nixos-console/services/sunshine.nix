{ lib, pkgs, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # needed for KMS display capture
    openFirewall = true;
    package = pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages;
    };
  };

  # Avahi for network discovery (Moonlight clients find Sunshine via mDNS).
  # nixpkgs' sunshine module still sets the deprecated publish.enable/userServices
  # options (via mkDefault); force them off so only our settings.publish below applies.
  services.avahi = {
    enable = true;
    publish.enable = lib.mkForce null;
    publish.userServices = lib.mkForce null;
    settings.publish = {
      "disable-publishing" = false;
      disable-user-service-publishing = false;
      publish-addresses = true;
    };
  };
}
