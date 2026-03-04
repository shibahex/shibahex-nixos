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

    # ScratchPad for niri and a script to keep dynamic workspaces, just define all these workspaces and assign them to a monitor
    niri-scratchpad
    (pkgs.writeShellScriptBin "workspace-per-monitor" ''
      SLOT=$1
      ACTION=''${2:-focus}
      CURRENT=$(niri msg -j focused-output | grep -oP '"name":"\K[^"]*')
      declare -A MAIN=([9]=misc [8]=docs [7]=mail [6]=media [5]=chat [4]=files [3]=term [2]=dev [1]=web)
      declare -A SIDE=([1]=misc2 [2]=docs2 [3]=mail2 [4]=media2 [5]=chat2 [6]=files2 [7]=term2 [8]=dev2 [9]=web2)
      declare -A SIDELEFT=([9]=misc3 [8]=docs3 [7]=mail3 [6]=media3 [5]=chat3 [4]=files3 [3]=term3 [2]=dev3 [1]=web3)

      MAIN_MON="${variables.mainMonitor}"
      SIDE_RIGHT="${if variables.sideMonitorRight != null then variables.sideMonitorRight else ""}"
      SIDE_LEFT="${if variables.sideMonitorLeft != null then variables.sideMonitorLeft else ""}"

      if [ "$CURRENT" = "$MAIN_MON" ]; then
        WS="''${MAIN[$SLOT]}"
      elif [ -n "$SIDE_RIGHT" ] && [ "$CURRENT" = "$SIDE_RIGHT" ]; then
        WS="''${SIDE[$SLOT]}"
      elif [ -n "$SIDE_LEFT" ] && [ "$CURRENT" = "$SIDE_LEFT" ]; then
        WS="''${SIDELEFT[$SLOT]}"
      else
        WS="''${MAIN[$SLOT]}"
      fi

      if [ "$ACTION" = "move" ]; then niri msg action move-column-to-workspace "$WS"
      else niri msg action focus-workspace "$WS"; fi
    '')
  ];

  # xdg.portal is already configured in modules/applications/flatpak.nix
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

  services.displayManager.ly.enable = lib.mkDefault true;
}
