{
  config,
  pkgs,
  lib,
  host,
  self,
  ...
}:
let
  pm = config.modules.powerManagement;

  # X11 has no idle-triggered suspend of its own; this mirrors niri's
  # swayidle timeouts so an unattended DWM session blanks, locks, and
  # (optionally) sleeps instead of just burning battery. Each enabled
  # feature contributes one stage, keyed by the absolute idle time (in
  # seconds) it should fire at; stages are independent and may come from
  # any combination of screenOff/hibernate.
  screenOffStage = lib.optional pm.screenOff.enable {
    time = pm.screenOff.timeout;
    cmd = "${pkgs.xset}/bin/xset dpms force off";
    cancel = "${pkgs.xset}/bin/xset dpms force on";
  };
  lockStage = lib.optional (pm.hibernate.enable && pm.hibernate.lock.enable) {
    time = pm.hibernate.lock.timeout;
    cmd = "${pkgs.slock}/bin/slock & ${pkgs.xset}/bin/xset dpms force off";
    cancel = "";
  };
  hibernateStage = lib.optional pm.hibernate.enable {
    time = pm.hibernate.idleTimeout;
    cmd = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    cancel = "";
  };
  stages = lib.sort (a: b: a.time < b.time) (screenOffStage ++ lockStage ++ hibernateStage);
  idleEnable = stages != [ ];

  # xidlehook's --timer durations are chained: each one counts from when
  # the previous timer fired, not from the start of idle. Convert our
  # absolute per-stage times into those deltas.
  chainedStages =
    let
      go =
        prevTime: xs:
        if xs == [ ] then
          [ ]
        else
          let
            s = builtins.head xs;
            rest = builtins.tail xs;
          in
          [ (s // { delta = s.time - prevTime; }) ] ++ go s.time rest;
    in
    go 0 stages;

  idleExec = ''
    ${pkgs.xidlehook}/bin/xidlehook \
      --not-when-audio \
      --not-when-fullscreen \
      ${lib.concatMapStringsSep " \\\n      " (
        s: ''--timer ${toString s.delta} "${s.cmd}" "${s.cancel}"''
      ) chainedStages}
  '';
in
{
  config = lib.mkIf config.modules.desktop.dwm.enable {
    services.xserver = {
      enable = lib.mkDefault true;
      windowManager.dwm.enable = true;
    };

    nixpkgs.overlays = [
      (
        final: prev:
        let
          safeImport =
            path:
            if builtins.pathExists path then
              let
                val = import path;
              in
              if builtins.isFunction val then val { inherit pkgs lib; } else val
            else
              { };

          dwmCfg = safeImport "${self}/hosts/${host}/dwm-config/dwm/config.nix";
          dmenuCfg = safeImport "${self}/hosts/${host}/dwm-config/dmenu/config.nix";
          stCfg = safeImport "${self}/hosts/${host}/dwm-config/st/config.nix";
          slstatusCfg = safeImport "${self}/hosts/${host}/dwm-config/slstatus/config.nix";

          writeConfig = text: pkgs.writeText "config.h" text;
        in
        {
          dwm = prev.dwm.overrideAttrs (_: {
            patches = [ ];
            postPatch = lib.optionalString (dwmCfg ? dwmConfig) ''
              cp ${writeConfig dwmCfg.dwmConfig} config.h
            '';
          });

          dmenu = prev.dmenu.overrideAttrs (_: {
            patches = [ ];
            postPatch = lib.optionalString (dmenuCfg ? dmenuConfig) ''
              cp ${writeConfig dmenuCfg.dmenuConfig} config.h
            '';
          });

          st = prev.st.overrideAttrs (_: {
            patches = [ ];
            postPatch = lib.optionalString (stCfg ? stConfig) ''
              cp ${writeConfig stCfg.stConfig} config.h
            '';
          });

          slstatus = prev.slstatus.overrideAttrs (_: {
            patches = [ ];
            postPatch = lib.optionalString (slstatusCfg ? slstatusConfig) ''
              cp ${writeConfig slstatusCfg.slstatusConfig} config.h
            '';
          });
        }
      )
    ];

    environment.systemPackages =
      with pkgs;
      [
        dwm
        dmenu
        st
        slstatus
        xinit
      ]
      ++ lib.optionals idleEnable [
        xidlehook
        xset
      ]
      ++ lib.optional (lockStage != [ ]) slock;

    systemd.user.services.slstatus = {
      description = "slstatus - suckless status monitor";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      unitConfig.ConditionEnvironment = "!WAYLAND_DISPLAY";

      serviceConfig = {
        ExecStart = "${pkgs.slstatus}/bin/slstatus";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };

    systemd.user.services.xidlehook = lib.mkIf idleEnable {
      description = "xidlehook - idle-triggered screen off / lock / suspend for DWM";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      # X11-only: under a Wayland session (niri) it segfaults in a restart loop
      unitConfig.ConditionEnvironment = "!WAYLAND_DISPLAY";
      startLimitBurst = 5;
      startLimitIntervalSec = 60;

      serviceConfig = {
        ExecStart = idleExec;
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
