{
  pkgs,
  lib,
  inputs,
  host,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix { pkgs = pkgs; };
  niri-scratchpad = inputs.niri-scratchpad-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home-manager.users.${variables.hostName} =
    lib.mkIf (builtins.pathExists ../../hosts/${host}/niri-config)
      {
        home.stateVersion = "25.05";
        xdg.configFile."niri" = {
          source = ../../hosts/${host}/niri-config;
          recursive = true;
        };
      };

  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    noctalia-shell
    fuzzel
    swaylock
    wl-clipboard
    satty

    # Per Monitor Workspaces
    xwayland-satellite
    alacritty
    niri-scratchpad
  ];

  # xdg.portal is already configured in modules/applications/flatpak.nix
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

  services.displayManager.ly.enable = lib.mkDefault true;
}
