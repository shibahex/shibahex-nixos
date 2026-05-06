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
  # Override noctalia-qs to 0.0.12 so noctalia-shell picks it up
  nixpkgs.overlays = [
    (final: prev: {
      noctalia-qs = prev.noctalia-qs.overrideAttrs (old: rec {
        version = "0.0.12";
        src = prev.fetchFromGitHub {
          owner = "noctalia-dev";
          repo = "noctalia-qs";
          tag = "v${version}";
          hash = "sha256-79JP2QTdvp1jg7HGxAW+xzhzhLnlKUi8yGXq9nDCeH0=";
        };
        patches = [ ]; # drop the patch - verify if 0.0.12 includes the fix upstream
      });
    })
  ];

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
    ])
    ++ lib.optional (dynamic-workspace ? script) dynamic-workspace.script;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  programs.niri.enable = true;
}
