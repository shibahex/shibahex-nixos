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
    swaybg
    wl-clipboard
    xwayland-satellite
    alacritty
  ];

  # xdg.portal is already configured in modules/applications/flatpak.nix
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

  services.displayManager.ly.enable = lib.mkDefault true;
}
