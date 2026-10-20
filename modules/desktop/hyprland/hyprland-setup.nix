{
  pkgs,
  lib,
  inputs,
  host,
  self,
  username,
  stateVersion,
  ...
}:
let
  variables = import "${self}/hosts/${host}/variables.nix" { pkgs = pkgs; };
in
{
  home-manager.users.${username} =
    lib.mkIf (builtins.pathExists "${self}/hosts/${host}/hypr-config")
      {
        home.stateVersion = "${stateVersion}";

        # Maps your host's hypr-config directory to ~/.config/hypr
        # Place your hyprland.lua inside ${self}/hosts/${host}/hypr-config/
        xdg.configFile."hypr" = {
          source = "${self}/hosts/${host}/hypr-config";
          recursive = true;
        };
      };

  environment.systemPackages = (
    with pkgs;
    [
      fuzzel
      swaylock
      wl-clipboard
      satty
      xwayland-satellite
      jq
      ghostty
      waybar # Added for Hyprland
      hyprlock # Added for Hyprland

      # nix packages search
      (pkgs.writeShellScriptBin "nix-packages" ''
        pkg=$(nix search nixpkgs ^ --json \
          | jq -r 'to_entries[] | "\(.key | ltrimstr("legacyPackages.x86_64-linux.")) — \(.value.description // "")"' \
          | fuzzel --dmenu --width=120 --lines=25 \
          | cut -d" " -f1)
        [ -z "$pkg" ] && exit
        action=$(printf "Copy to clipboard\nOpen in browser" | fuzzel --dmenu --width=40 --lines=2)
        case "$action" in
            "Copy to clipboard") echo -n "$pkg" | wl-copy ;;
            "Open in browser")   xdg-open "https://search.nixos.org/packages?query=$pkg" ;;
        esac
      '')
      (pkgs.makeDesktopItem {
        name = "nix-packages";
        desktopName = "Nix Package Search";
        exec = "nix-packages";
        icon = "nix-snowflake";
        categories = [ "System" ];
        keywords = [
          "nix"
          "packages"
          "search"
        ];
      })

      # zoom web app
      (pkgs.writeShellScriptBin "zoom-web" ''
        chromium --app=https://app.zoom.us/wc
      '')
      (pkgs.makeDesktopItem {
        name = "zoom-web";
        desktopName = "Zoom (Web)";
        exec = "zoom-web";
        icon = "zoom";
        categories = [
          "Network"
          "VideoConference"
        ];
        keywords = [
          "zoom"
          "meeting"
          "video"
          "call"
        ];
      })

      #my fitness pal
      (pkgs.writeShellScriptBin "fitnesspal-web" ''
        chromium --app=https://www.myfitnesspal.com/food/diary
      '')

      (pkgs.makeDesktopItem {
        name = "myfitnesspal";
        desktopName = "myfitnesspal (Web)";
        exec = "fitnesspal-web";
        icon = "fitness";
        categories = [
          "Utility"
          "Network"
        ];
        keywords = [
          "fitness"
          "health"
          "tracker"
          "calories"
        ];
      })

    ]
  );

  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
