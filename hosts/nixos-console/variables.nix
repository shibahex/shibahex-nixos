{ pkgs }:
let
  mainMonitor = "DP-2";
  sideMonitorRight = null;
  sideMonitorLeft = null;
in
{
  # Host
  hostName = "nixos-console";
  timeZone = "America/New_York";
  hostId = "5ab03f50";
  defaultShell = "nushell";
  desktops = [
    "dwm"
    "niri"
  ];

  # Monitors
  mainMonitor = mainMonitor;
  sideMonitorRight = sideMonitorRight;
  sideMonitorLeft = sideMonitorLeft;
}
