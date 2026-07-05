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
      description = "Installs kdePackages.plasma.plasma-bigscreen and registers its plasma-bigscreen-wayland session via services.displayManager.sessionPackages.";
    };

    cecSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Loads cec kernel module, installs libcec + v4l-utils so a TV remote can drive Plasma Bigscreen over HDMI-CEC.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    services.displayManager.sessionPackages = [ plasma-bigscreen ];

    xdg.portal.configPackages = [ plasma-bigscreen ];

    boot.kernelModules = lib.optional cfg.cecSupport "cec";

    environment.systemPackages = [
      plasma-bigscreen
      pkgs.kdePackages.kdeconnect-kde
    ]
    ++ lib.optionals cfg.cecSupport [
      pkgs.libcec
      pkgs.v4l-utils
    ];
  };
}
