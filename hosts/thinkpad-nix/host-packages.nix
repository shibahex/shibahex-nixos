{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    (anki.withAddons [ ankiAddons.review-heatmap ])
    timer
    btop

    (mpv.override { yt-dlp = pkgs.yt-dlp-light; })

    tmux
    openvpn

    vesktop

    librewolf

    fastfetch
    alacritty

    blender
  ];

  virtualisation.vmware.host.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.users.${username}.extraGroups = [ "vboxusers" ];
}
