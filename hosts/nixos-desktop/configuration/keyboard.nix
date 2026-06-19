{ pkgs, ... }:
{

  # Try to fix wireless keyboard disconnecting on sleep
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0c45", ATTR{idProduct}=="fefe", TEST=="power/control", ATTR{power/control}="on"
  '';
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [ pkgs.via ];

}
