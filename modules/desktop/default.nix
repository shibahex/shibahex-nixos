{
  pkgs,
  lib,
  ...
}:
let
  mkDesktop = name: lib.mkEnableOption name;
in
{
  imports = [
    ./dwm/dwm-setup.nix
    ./niri/niri-setup.nix
    ./oxwm/oxwm-setup.nix
    ./hyprland/hyprland-setup.nix
    ./plasma/plasma-bigscreen.nix
  ];

  options.modules.desktop = {
    dwm.enable = mkDesktop "dwm";
    niri.enable = mkDesktop "niri";
    oxwm.enable = mkDesktop "oxwm";
    hyprland.enable = mkDesktop "Hyprland";
  };
  config = {
    stylix.enable = lib.mkDefault true;
    stylix.base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
    # Without a real icon theme only hicolor is installed, so icon lookups fail.
    # noctalia's Active Window widget then retries in a loop, the shell falls
    # behind niri's event stream, and the workspaces widget freezes.
    stylix.polarity = lib.mkDefault "dark";
    stylix.icons = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.papirus-icon-theme;
      dark = lib.mkDefault "Papirus-Dark";
      light = lib.mkDefault "Papirus-Light";
    };
    home-manager.sharedModules = [ { stylix.targets.rofi.enable = false; } ];
    services.displayManager.ly.enable = lib.mkDefault true;
  };
}
