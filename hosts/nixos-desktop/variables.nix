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

  # For Nvidia Prime support
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  nvidiaID = "PCI:1:0:0";

  # GPU passthrough
  vfioIds = "10de:1b06,10de:10ef";

  defaultShell = "nushell";

  monitorRules = [
    {
      name = "Gaming monitors";
      outputs_connected = [
        mainMonitor
        sideMonitorRight
      ];
      configure_row = [
        mainMonitor
        sideMonitorRight
      ];
      primary = mainMonitor;
      atomic = true;
      execute_after = [
        "${pkgs.xorg.xrandr}/bin/xrandr --output ${mainMonitor} --mode 3840x2160 --rate 144 --dpi 192 --primary"
        "${pkgs.xorg.xrandr}/bin/xrandr --output ${sideMonitorRight} --mode 2560x1440 --rate 100 --rotate normal" # --rotate right"
      ];
    }
  ];

  # Set network hostId if required (needed for zfs)
  hostId = "5ab03f50";

}
