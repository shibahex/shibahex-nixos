{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # For timing tasks and productivity
    timer

    btop

    mpv
    tmux
    openvpn

    # Extra browser
    librewolf

    #Yubikey
    yubikey-manager

    linuxPackages.usbip
  ];

  services.xrdp = {
    enable = true;
    defaultWindowManager = "dwm";
    openFirewall = true;
  };

  powerManagement.cpuFreqGovernor = "performance";
  services.pcscd.enable = true;


  # for usbip (yubikey)
  boot.kernelModules = [
    "usbip-core"
    "vhci-hcd"
  ];

}
