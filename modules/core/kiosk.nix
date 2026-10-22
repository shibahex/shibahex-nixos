{
  lib,
  config,
  host,
  username,
  ...
}:
let
  cfg = config.modules.kiosk;
in
{
  options.modules.kiosk = {
    enable = lib.mkEnableOption "console-style boot: silent splash, auto-login and auto-upgrades";
    session = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "plasma-bigscreen-wayland";
    };
    autoUpgrade = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    flake = lib.mkOption {
      type = lib.types.str;
      default = "git+https://github.com/shibahex/nixos-config#${host}";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix.targets.plymouth.enable = lib.mkDefault false;
    boot = {
      plymouth.enable = lib.mkDefault true;
      initrd.systemd.enable = lib.mkDefault true;
      consoleLogLevel = lib.mkDefault 3;
      initrd.verbose = lib.mkDefault false;
      kernelParams = [
        "quiet"
        "splash"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];
      # The menu still opens on any keypress
      loader.timeout = lib.mkDefault 0;
    };

    services.displayManager = {
      autoLogin.enable = lib.mkDefault true;
      autoLogin.user = lib.mkDefault username;
      defaultSession = lib.mkIf (cfg.session != null) cfg.session;
    };

    system.autoUpgrade = lib.mkIf cfg.autoUpgrade {
      enable = true;
      flake = cfg.flake;
    };
  };
}
