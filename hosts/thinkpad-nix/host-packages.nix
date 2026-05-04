{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
    (anki.withAddons [ ankiAddons.review-heatmap ])
    # For timing tasks and productivity
    timer
    btop

    (mpv.override { yt-dlp = pkgs.yt-dlp-light; })

    tmux
    openvpn

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
    alacritty

  ];
  #recording
  programs.obs-studio = {
    enable = true;
  };

  # ffmpegthumbnailer and tumbler for mp4 thumbnails
  services.tumbler.enable = true;

  # for looking glass
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 $USER kvm -" ];

  programs.gamemode.enable = true;
  virtualisation.docker.enable = true;
}
