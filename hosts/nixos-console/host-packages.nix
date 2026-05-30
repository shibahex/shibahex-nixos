{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    (mpv.override { yt-dlp = pkgs.yt-dlp-light; })
    librewolf
    fastfetch
    thunar
    ffmpegthumbnailer
    alacritty

    ryubing
    partyDeck
  ];
  #recording
  programs.obs-studio = {
    enable = true;
  };

  # ffmpegthumbnailer and tumbler for mp4 thumbnails
  services.tumbler.enable = true;

  programs.gamemode.enable = true;
  virtualisation.docker.enable = true;

  # AI server
  networking.firewall.allowedTCPPorts = [
    6969
  ];
}
