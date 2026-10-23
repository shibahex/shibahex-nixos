{ ... }:
{
  machine = {
    shell = "nushell";
    monitors.main = "DP-2";
  };

  modules = {
    desktop = {
      dwm.enable = true;
      niri.enable = true;
      bigscreen.enable = true;
    };
    kiosk = {
      enable = true;
      session = "plasma-bigscreen-wayland";
    };
    recording.enable = true;
    fileManager.enable = true;
    gaming.enable = true;
    docker.enable = true;
    performance.enable = true;
    powerManagement = {
      screenOff = {
        enable = true;
        timeout = 300; # 5 min: turn the HDMI output off
      };
      hibernate = {
        enable = false; # hosts an LLM server (services/llm.nix); idle is input-only and would suspend it mid-request
      };
    };
  };
}
