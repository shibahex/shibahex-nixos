{ pkgs }:
let
  mainMonitor = "DP-4";
  sideMonitorRight = "DP-5";
  sideMonitorLeft = null;
in
{
  # Host
  hostName = "shiba";
  timeZone = "America/New_York";
  hostId = "5ab03f50";
  defaultShell = "nushell";

  # GPU
  nvidiaID = "PCI:1:0:0";
  vfioIds = "10de:1b06,10de:10ef";

  # Monitors
  mainMonitor = mainMonitor;
  sideMonitorRight = sideMonitorRight;
  sideMonitorLeft = sideMonitorLeft;

  # DWM monitor rules (for grobi)
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
        "${pkgs.xrandr}/bin/xrandr --output ${mainMonitor} --mode 3840x2160 --rate 144 --dpi 192 --primary"
        "${pkgs.xrandr}/bin/xrandr --output ${sideMonitorRight} --mode 2560x1440 --rate 100 --rotate normal"
      ];
    }
  ];
}
