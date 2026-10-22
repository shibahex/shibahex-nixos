{ lib, pkgs, ... }:
{
  # EasyEffects can't add plugins without dconf
  programs.dconf.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    easyeffects
    pavucontrol
    spotify
  ];
}
