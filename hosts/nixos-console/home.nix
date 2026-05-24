{ pkgs, ... }:
{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 120;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 120;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      }
      {
        timeout = 300;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
  };
}
