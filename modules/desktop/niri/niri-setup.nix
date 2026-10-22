{
  config,
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
  inherit (config.machine) monitors;
  niri-scratchpad = inputs.niri-scratchpad-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
  dynamic-workspace = lib.optionalAttrs (monitors.main != null) (
    import ./niri-scratchpad.nix {
      inherit
        pkgs
        lib
        monitors
        host
        self
        ;
    }
  );
in
{
  config = lib.mkIf config.modules.desktop.niri.enable {
    home-manager.users.${username} =
      lib.mkIf (builtins.pathExists "${self}/hosts/${host}/niri-config")
        {
          home.stateVersion = "${stateVersion}";
          xdg.configFile."niri" = {
            source = "${self}/hosts/${host}/niri-config";
            recursive = true;
          };
          xdg.configFile."niri/configs/workspaces.kdl" = lib.mkForce (
            lib.mkIf (dynamic-workspace ? workspacesKdl) {
              source = dynamic-workspace.workspacesKdl;
            }
          );
        };
    environment.systemPackages =
      (with pkgs; [
        # noctalia-shell: temporarily disabled, fails to build against the
        # Qt 6.12 bump (nixpkgs noctalia-dev/noctalia#4761, unfixed upstream)
        fuzzel
        swaylock
        wl-clipboard
        satty
        xwayland-satellite
        ghostty
        niri-scratchpad
        jq

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

        (pkgs.writeShellScriptBin "slack-web" ''
          chromium --app=https://app.slack.com/client/T03P4BU6M61/C0B7W9C17K3
        '')
        (pkgs.makeDesktopItem {
          name = "slack-web";
          desktopName = "slack (Web)";
          exec = "slack-web";
          icon = "slack";
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

      ])
      ++ lib.optional (dynamic-workspace ? script) dynamic-workspace.script;
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
        };
        niri = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
        };
      };
    };
    programs.niri.enable = lib.mkDefault true;
  };
}
