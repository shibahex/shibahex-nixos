{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    spice-vdagent
    xorg.xf86videovirtio
  ];
  services.xserver.videoDrivers = [ "virtio" ];
  services.xserver.libinput.enable = true;
}
