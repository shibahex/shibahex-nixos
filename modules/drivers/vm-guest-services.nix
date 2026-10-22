{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.vm.guest-services;
in
{
  options.vm.guest-services = {
    enable = mkEnableOption "virtual machine guest services";
  };

  config = mkIf cfg.enable {
    services.qemuGuest.enable = mkDefault true;
    services.spice-vdagentd.enable = mkDefault true;
    services.spice-webdavd.enable = mkDefault true;
  };
}
