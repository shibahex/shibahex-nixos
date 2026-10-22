{ lib, config, ... }:
let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming = {
    enable = lib.mkEnableOption "Steam and gamemode";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = lib.mkDefault true;
    programs.gamemode.enable = lib.mkDefault true;
  };
}
