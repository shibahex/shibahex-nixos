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
      # OBS's virtual camera.
      {
        boot.kernelModules = [ "v4l2loopback" ];
        # Kernel's `dev` output now ships System.map, so kbuild's modules_install
        # runs depmod for out-of-tree modules too; v4l2loopback's own modules.alias
        # then collides with the kernel's when NixOS merges them (nixpkgs#576406).
        # DEPMOD=true no-ops that depmod call; the final aggregate depmod handles it.
        boot.extraModulePackages = [
          (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
            makeFlags = (old.makeFlags or [ ]) ++ [ "DEPMOD=true" ];
          }))
        ];
      }
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
