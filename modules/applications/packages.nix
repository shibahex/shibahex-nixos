{ pkgs, ... }:
{
  hardware.graphics.enable32Bit = true;
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    #Browser
    # ungoogled-chromium
    (ungoogled-chromium.override {
      commandLineArgs = [
        "--enable-blink-features=DisableHardwareNoiseSuppression"
        "--disable-gpu-memory-buffer-video-frames"
        "--disable-gpu-memory-buffer-compositor-resources"
      ];
    })
    # Password Manager
    _1password-gui

    # Terminal Command to see file structures
    tree

    # Screenshots
    flameshot

    #easy kill command
    killall
  ];
}
