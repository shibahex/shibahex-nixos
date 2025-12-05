{ pkgs }: {
  #Mainly used for hardware.nix or etc, inital setup in flake.nix has your hostname
  hostName = "nixos-thinkpad";

  # Git Configuration
  gitUsername = "shiba";
  gitEmail = "shiba@nixos-desktop";
  timeZone = "America/New_York";

  # For Nvidia Prime support
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0"; # Update with your integrated GPU ID
  nvidiaID = "PCI:1:0:0"; # Update with your NVIDIA GPU ID

  # Startup Applications
  startupApps = [ ];
  monitorRules = [{}];
#    name = "";
#    outputs_connected = [ "eDP-1" ];
#    configure_single = "eDP-1";
#    primary = true;
#    atomic = true;
#    execute_after = [
#    "${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --mode 1920x1080 --rate 60 --primary"
#    ];
#  }];


  defaultShell = "nushell";

  # Set network hostId if required (needed for zfs)
  hostId = "5ab03f50";
}
