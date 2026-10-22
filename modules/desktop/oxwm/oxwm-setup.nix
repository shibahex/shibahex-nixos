{ lib, config, ... }:
{
  config = lib.mkIf config.modules.desktop.oxwm.enable {
    services.xserver.windowManager.oxwm.enable = true;
  };
}
