{ pkgs, lib, ... }:
{
  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    walker
    mako
    fuzzel
    swaylock
    wl-clipboard
    xwayland-satellite
    alacritty
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = [ "gnome" ];
  };

  services.displayManager.ly.enable = lib.mkDefault true;
}
