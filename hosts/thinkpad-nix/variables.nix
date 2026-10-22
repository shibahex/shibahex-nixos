{ ... }:
{
  machine = {
    shell = "nushell";
    monitors.main = "eDP-1";
  };

  modules = {
    desktop = {
      dwm.enable = true;
      niri.enable = true;
    };
    virtualisation.lookingGlass = true;
    yubikey = {
      enable = true;
      usbip = "client";
    };
    recording.enable = true;
    fileManager.enable = true;
    gaming.enable = true;
    docker.enable = true;
  };
}
