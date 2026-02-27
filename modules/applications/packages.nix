{ pkgs, ... }:
{
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    #Browser
    librewolf-bin
    ungoogled-chromium

    # Password Manager
    _1password-gui

    # Terminal Command to see file structures
    tree

    # Screenshots
    flameshot
  ];
}
