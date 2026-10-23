{ lib, config, ... }:
let
  cfg = config.modules.powerManagement;
in
{
  options.modules.powerManagement = {
    # Standalone "just blank the display" timer. Independent of hibernate,
    # so it works on its own for an always-on host (e.g. a console on a TV
    # that should just turn the HDMI output off, never suspend) and can also
    # be combined with hibernate to blank earlier than the eventual suspend.
    screenOff = {
      enable = lib.mkEnableOption "turning the display off after a period of idle";
      timeout = lib.mkOption {
        type = lib.types.int;
        default = 300;
        example = 300;
        description = ''
          Seconds of idle before the display turns off. Resumes on the next
          input.

          Independent of `hibernate` — this timer only ever blanks the
          screen, it never locks or suspends anything. If `hibernate` is
          also enabled, both timers run on the same idle clock: whichever
          fires first (usually this one) just blanks the screen, then
          `hibernate.idleTimeout` still fires on schedule afterwards.
        '';
      };
    };

    hibernate = {
      enable = lib.mkEnableOption ''
        suspend-then-hibernate on idle and (optionally) lid close.
        Idling for `idleTimeout` suspends immediately; if still asleep
        after `hibernateDelay`, systemd wakes briefly and hibernates to
        disk instead of slowly draining the battery over hours or days.
        Useful for any host that might sit unattended for a long time, not
        just laptops
      '';
      idleTimeout = lib.mkOption {
        type = lib.types.int;
        default = 300;
        example = 1200;
        description = ''
          Seconds of idle before suspending. Must be greater than
          `lock.timeout` when `lock.enable` is true.

          Example: a console with `screenOff.timeout = 300` (5 min) and
          `hibernate.idleTimeout = 1200` (20 min) blanks the display at the
          5-minute mark, then suspends-then-hibernates at the 20-minute
          mark.
        '';
      };

      lock = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Lock the session (and blank the display) `lock.timeout` seconds
            before suspending. Set to `false` for kiosk-style hosts with no
            user session worth protecting — e.g. a console, where
            `screenOff` already covers blanking the display and there's
            nothing to lock.
          '';
        };
        timeout = lib.mkOption {
          type = lib.types.int;
          default = 120;
          example = 120;
          description = ''
            Seconds of idle before locking and blanking the display, ahead
            of `idleTimeout`. Ignored when `lock.enable` is false.
          '';
        };
      };

      hibernateDelay = lib.mkOption {
        type = lib.types.str;
        default = "30min";
        example = "30min";
        description = ''
          How long systemd stays suspended before waking briefly to
          hibernate to disk, per {manpage}`systemd-sleep.conf(5)`'s
          `HibernateDelaySec`. This is what actually stops a laptop left
          asleep for days from draining its battery to zero: it naps in S3
          for this long, then automatically hibernates (near-zero power
          draw) if nobody's woken it up by then.

          Requires a working resume target (`boot.resumeDevice` plus swap
          sized for RAM) — if hibernation can't actually happen, the host
          just stays suspended indefinitely like before this option
          existed.
        '';
      };

      onLidClose = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether closing the lid also triggers suspend-then-hibernate
          immediately (via `systemd-logind`'s `HandleLidSwitch`), rather
          than waiting for `idleTimeout`. Has no effect on hosts without a
          lid (desktops, consoles) — leave it at the default there.
        '';
      };
    };
  };

  config = lib.mkIf cfg.hibernate.enable {
    assertions = [
      {
        assertion = !cfg.hibernate.lock.enable || cfg.hibernate.lock.timeout < cfg.hibernate.idleTimeout;
        message = "modules.powerManagement.hibernate.lock.timeout must be less than idleTimeout";
      }
    ];

    services.logind.settings.Login = lib.mkIf cfg.hibernate.onLidClose {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
    };

    systemd.sleep.settings.Sleep.HibernateDelaySec = cfg.hibernate.hibernateDelay;
  };
}
