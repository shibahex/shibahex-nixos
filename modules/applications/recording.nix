{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.recording;
in
{
  options.modules.recording = {
    enable = lib.mkEnableOption "OBS Studio";
    nvidiaLibs = lib.mkEnableOption "an obs wrapper that puts the Nvidia driver libraries on LD_LIBRARY_PATH";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.nvidiaLibs {
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "obs" ''
            export LD_LIBRARY_PATH=${config.boot.kernelPackages.nvidiaPackages.stable}/lib:$LD_LIBRARY_PATH
            exec ${pkgs.obs-studio}/bin/obs "$@"
          '')
        ];
      })
      (lib.mkIf (!cfg.nvidiaLibs) { programs.obs-studio.enable = lib.mkDefault true; })
    ]
  );
}
