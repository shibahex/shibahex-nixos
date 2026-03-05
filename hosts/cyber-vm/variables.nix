{ pkgs }:
{
  hostName = "shiba";
  timeZone = "America/New_York";
  hostId = "5ab03f50";
  defaultShell = "nushell";

  # No monitors on VM
  mainMonitor = null;
  sideMonitorRight = null;
  sideMonitorLeft = null;
  monitorRules = [ ];
  desktops = [
    "dwm"
  ];
}
