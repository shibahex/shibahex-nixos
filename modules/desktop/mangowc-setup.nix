{ config, pkgs, ... }:

{
  programs.mangowc.enable = true;

  environment.systemPackages = with pkgs; [
    foot
    wmenu
    wl-clipboard
    grim
    slurp
    swaybg
    firefox
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
