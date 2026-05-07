{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    spice-vdagent
  ];
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.libinput.enable = true;
}
