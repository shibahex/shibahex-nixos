{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
    (anki.withAddons [ ankiAddons.review-heatmap ])
    # For timing tasks and productivity
    timer
    btop

    mpv
    tmux
    openvpn

    # Recording App
    obs-studio

    # Discord
    vesktop

    # Extra browser
    librewolf

    #Yubikey
    yubikey-manager

    linuxPackages.usbip

    fastfetch

    thunar
    ffmpegthumbnailer

  ];

  # ffmpegthumbnailer and tumbler for mp4 thumbnails
  services.tumbler.enable = true;

  # for looking glass
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 $USER kvm -" ];

  programs.gamemode.enable = true;
  virtualisation.docker.enable = true;

  # Change to save battery life
  powerManagement.cpuFreqGovernor = "performance";
}
