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
  dynamic-workspace = lib.optionalAttrs (variables.mainMonitor != null) (
    import ./niri-scratchpad.nix {
      inherit
        pkgs
        lib
        variables
        host
        ;
    }
  );
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
        xdg.configFile."niri/configs/workspaces.kdl" = lib.mkIf (dynamic-workspace ? workspacesKdl) {
          source = dynamic-workspace.workspacesKdl;
        };
      };

  environment.systemPackages =
    with pkgs;
    [
      noctalia-shell
      fuzzel
      swaylock
      wl-clipboard
      satty
      xwayland-satellite
      alacritty

      ## Scripts to make niri scratchpad work with dynamic-workspace
      niri-scratchpad
    ]
    ++ lib.optional (dynamic-workspace ? script) dynamic-workspace.script;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  services.displayManager.ly.enable = lib.mkDefault true;
}
