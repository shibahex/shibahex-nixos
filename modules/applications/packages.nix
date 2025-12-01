{ pkgs, ... }: {
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    #Browser
    # librewolf-bin
    ungoogled-chromium

    # Password Manager
    _1password-gui

    # Terminal Command to see file structures
    tree

    # Recording App
    obs-studio

    # Discord
    vesktop

    # Screenshots
    flameshot
  ];
}
