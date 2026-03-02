{ pkgs }:
let
  mainMonitor = "DP-0";
  sideMonitorRight = "DP-2";

in
{
  #Mainly used for hardware.nix or etc, inital setup in flake.nix has your hostname
  hostName = "shiba";

  # Git Configuration
  timeZone = "America/New_York";

  defaultShell = "nushell";
  services.xserver.extraConfig = ''
    Section "Device"
      Identifier "Device-nvidia"
      Driver "nvidia"
      BusID "PCI:7:0:0"
    EndSection

    Section "Screen"
      Identifier "Screen-nvidia"
      Device "Device-nvidia"
    EndSection

  '';

  monitorRules = [ ];
  services.pcscd.enable = true;


  # for usbip (yubikey)
  boot.kernelModules = [
    "usbip-core"
    "vhci-hcd"
  ];

  # Set network hostId if required (needed for zfs)
  hostId = "5ab03f50";

}
