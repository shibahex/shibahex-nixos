# plasma-bigscreen.nix
{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.plasmaBigscreen;
  inherit (pkgs.kdePackages.plasma) plasma-bigscreen;
in
{
  options.plasmaBigscreen = {
    enable = lib.mkEnableOption "Plasma Bigscreen TV shell" // {
      description = "Installs kdePackages.plasma.plasma-bigscreen and registers its plasma-bigscreen-wayland session via services.displayManager.sessionPackages. Exempt from VM smoke test: pulls in qtwebengine + full KDE Frameworks (binary-cache-dependent), and HDMI-CEC input can't be exercised in a VM.";
    };

    cecSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Loads cec kernel module, installs libcec + v4l-utils so a TV remote can drive Plasma Bigscreen over HDMI-CEC.";
    };

    defaultSession = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Makes plasma-bigscreen-wayland the default SDDM session (autologin target) instead of just a selectable option.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager = {
      sddm = lib.mkDefault {
        enable = true;
        wayland.enable = true;
      };
      sessionPackages = [ plasma-bigscreen ];
      defaultSession = lib.mkIf cfg.defaultSession "plasma-bigscreen-wayland";
    };

    xdg.portal.configPackages = [ plasma-bigscreen ];

    boot.kernelModules = lib.optional cfg.cecSupport "cec";

    environment.systemPackages = [
      plasma-bigscreen
    ]
    ++ lib.optionals cfg.cecSupport [
      pkgs.libcec
      pkgs.v4l-utils
    ];
  };
}
