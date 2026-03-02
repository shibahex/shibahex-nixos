{
  pkgs,
  lib,
  host,
  ...
}:
{
  services.xserver = {
    enable = true;
    windowManager.dwm.enable = true;
  };

  services.displayManager.ly.enable = true;

  nixpkgs.overlays = [
    (
      final: prev:
      let
        # helper to import config files safely
        safeImport =
          path:
          if builtins.pathExists path then
            let
              val = import path;
            in
            if builtins.isFunction val then val { inherit pkgs lib; } else val
          else
            { };

        # import all configs
        dwmCfg = safeImport ../../hosts/${host}/dwm-config/dwm/config.nix;
        dmenuCfg = safeImport ../../hosts/${host}/dwm-config/dmenu/config.nix;
        stCfg = safeImport ../../hosts/${host}/dwm-config/st/config.nix;
        slstatusCfg = safeImport ../../hosts/${host}/dwm-config/slstatus/config.nix;

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

  environment.systemPackages = with pkgs; [
    dwm
    dmenu
    st
    slstatus
  ];

  systemd.user.services.slstatus = {
    description = "slstatus - suckless status monitor";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.slstatus}/bin/slstatus";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
