{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.modules.desktop.bigscreen;
  inherit (pkgs.kdePackages.plasma) plasma-bigscreen;

  pm = config.modules.powerManagement;
  idleEnable = pm.screenOff.enable || pm.hibernate.enable;

  # Plasma Bigscreen runs on KWin, not niri/dwm, so screenOff/hibernate are
  # wired through KDE's own power daemon instead of swayidle/xidlehook.
  # PowerDevil keeps per-profile settings in ~/.config/powerdevilrc under
  # literal "[<Profile>][<Group>]" sections; "AC" is the profile used
  # whenever the device isn't on battery, which for a console is always.
  # AutoSuspendAction=1 and SleepMode=3 are PowerDevil's PowerButtonAction
  # ::Sleep and SleepMode::SuspendThenHibernate enum values — see
  # kdePackages.powerdevil's daemon/powerdevilenums.h.
  powerdevilSettings =
    lib.optionalAttrs pm.screenOff.enable {
      "AC][Display" = {
        TurnOffDisplayWhenIdle = true;
        TurnOffDisplayIdleTimeoutSec = pm.screenOff.timeout;
        DimDisplayWhenIdle = false;
        LockBeforeTurnOffDisplay = pm.hibernate.enable && pm.hibernate.lock.enable;
      };
    }
    // lib.optionalAttrs pm.hibernate.enable {
      "AC][SuspendAndShutdown" = {
        AutoSuspendAction = 1; # PowerButtonAction::Sleep
        AutoSuspendIdleTimeoutSec = pm.hibernate.idleTimeout;
        SleepMode = 3; # SleepMode::SuspendThenHibernate
      };
    };
in
{
  options.modules.desktop.bigscreen = {
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

    home-manager.users.${username} = lib.mkIf idleEnable {
      xdg.configFile."powerdevilrc".text = lib.generators.toINI {
        # KConfig's nested-group syntax is a literal "[Outer][Inner]"
        # section header; toINI's default mkSectionName would otherwise
        # escape those brackets.
        mkSectionName = lib.id;
      } powerdevilSettings;
    };
  };
}
