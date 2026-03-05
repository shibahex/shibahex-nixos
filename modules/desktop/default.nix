{
  pkgs,
  host,
  lib,
  config,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix { pkgs = pkgs; };
  desktops = variables.desktops or [ "dwm" ];
in
{
  # Dark theme
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";

  imports =
    (lib.optional (builtins.elem "dwm" desktops) ./dwm-setup.nix)
    ++ (lib.optional (builtins.elem "niri" desktops) ./niri-setup.nix);

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Cage extends the screen
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --asterisks
          --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
