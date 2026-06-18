{ pkgs
, lib
, inputs
, host
, self
, username
, stateVersion
, ...
}:
let
  variables = import "${self}/hosts/${host}/variables.nix" { pkgs = pkgs; };
  niri-scratchpad = inputs.niri-scratchpad-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
  dynamic-workspace = lib.optionalAttrs (variables.mainMonitor != null) (
    import ./niri-scratchpad.nix {
      inherit
        pkgs
        lib
        variables
        host
        self
        ;
    }
  );
in
{
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
      noctalia-shell
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
    ])
    ++ lib.optional (dynamic-workspace ? script) dynamic-workspace.script;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  programs.niri.enable = true;
}
