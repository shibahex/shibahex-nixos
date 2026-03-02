{ pkgs, ... }:
{
  # For easyeffects, cant add plugins without it.
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    easyeffects # for filers and plugins
    pavucontrol # manage audio devices
    spotify # music player
  ];
}
