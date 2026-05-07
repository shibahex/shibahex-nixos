{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # For timing tasks and productivity
    timer

    btop

    (mpv.override { yt-dlp = pkgs.yt-dlp-light; })

    alacritty
    tmux
    openvpn

    # Extra browser
    librewolf

    #Yubikey
    yubikey-manager

    linuxPackages.usbip
  ];

  # allow stuff like echo "10.129.x.x kobold.htb" | sudo tee -a /etc/hosts
  # so we can resolve the dns for htb labs
  environment.etc.hosts.mode = "0644";

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
