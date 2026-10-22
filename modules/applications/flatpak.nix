{ lib, pkgs, ... }:
{
  xdg.portal = {
    enable = lib.mkDefault true;
    config.common.default = lib.mkDefault [ "gtk" ];
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  services.flatpak.enable = lib.mkDefault true;
}
