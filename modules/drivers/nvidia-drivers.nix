{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.drivers.nvidia;
in
{
  options.drivers.nvidia = {
    enable = mkEnableOption "Nvidia drivers";
    # Turing (RTX 20) and newer only; Pascal and older need the proprietary module
    open = mkEnableOption "Nvidia open kernel modules";
  };
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = mkDefault true;
      # Saves VRAM across suspend; can break suspend on some setups
      powerManagement.enable = mkDefault false;
      powerManagement.finegrained = mkDefault false;
      open = cfg.open;
      nvidiaSettings = mkDefault true;
      package = mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
    };
    hardware.graphics = {
      enable = true;
      enable32Bit = mkDefault true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
    };
  };
}
