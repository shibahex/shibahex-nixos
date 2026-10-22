{ ... }:
{
  machine.shell = "nushell";

  modules = {
    desktop.dwm.enable = true;
    yubikey = {
      enable = true;
      usbip = "client";
    };
    performance = {
      enable = true;
      scheduler = null;
    };
  };
}
