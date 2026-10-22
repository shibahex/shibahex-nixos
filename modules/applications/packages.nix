{ lib, pkgs, ... }:
{
  programs.steam.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    (ungoogled-chromium.override {
      commandLineArgs = [
        "--enable-blink-features=DisableHardwareNoiseSuppression"
        "--disable-gpu-memory-buffer-video-frames"
        "--disable-gpu-memory-buffer-compositor-resources"
      ];
    })
    _1password-gui
    tree
    flameshot
    killall
  ];
}
