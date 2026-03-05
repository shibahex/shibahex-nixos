{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # For timing tasks and productivity
    timer

    btop

    mpv
    alacritty
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

  services.xserver.extraConfig = ''
    Section "Device"
      Identifier "Device-nvidia"
      Driver "nvidia"
      BusID "PCI:7:0:0"
    EndSection

    Section "Screen"
      Identifier "Screen-nvidia"
      Device "Device-nvidia"
    EndSection

  '';

}
