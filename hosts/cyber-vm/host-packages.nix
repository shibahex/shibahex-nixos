{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    timer

    btop

    (mpv.override { yt-dlp = pkgs.yt-dlp-light; })

    alacritty
    tmux
    openvpn

    librewolf
  ];

  # Writable /etc/hosts for adding HTB lab hostnames
  environment.etc.hosts.mode = "0644";

  services.xrdp = {
    enable = true;
    defaultWindowManager = "dwm";
    openFirewall = true;
  };

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
