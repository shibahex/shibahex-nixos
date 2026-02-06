{ pkgs }: {
  #Mainly used for hardware.nix or etc, inital setup in flake.nix has your hostname
  hostName = "shiba";

  # Git Configuration
  gitUsername = "shiba";
  gitEmail = "shiba@nixos-desktop";
  timeZone = "America/New_York";

  # For Nvidia Prime support
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  nvidiaID = "PCI:1:0:0";

  vfioIds = "10de:1b06,10de:10ef";
  # Startup Applications
  startupApps = [ ];

  defaultShell = "nushell";
  monitorRules = [{
    name = "Gaming monitors";
    outputs_connected = [ "DP-2" "DP-4" ];
    configure_row = [ "DP-4" "DP-2" ];
    primary = "DP-4";
    atomic = true;
    execute_after = [
      "${pkgs.xorg.xrandr}/bin/xrandr --output DP-4 --mode 3840x2160 --rate 144 --dpi 192"
      "${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 100 --rotate normal" # --rotate right"
    ];
  }];

  # Set network hostId if required (needed for zfs)
  hostId = "5ab03f50";

}
