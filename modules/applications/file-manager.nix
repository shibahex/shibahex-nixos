{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.fileManager;
in
{
  options.modules.fileManager = {
    enable = lib.mkEnableOption "Thunar with video thumbnails";
  };

  config = lib.mkIf cfg.enable {
    services.tumbler.enable = lib.mkDefault true;
    environment.systemPackages = with pkgs; [
      thunar
      ffmpegthumbnailer
    ];
  };
}
