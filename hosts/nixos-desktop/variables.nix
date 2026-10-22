{ pkgs, ... }:
let
  main = "DP-5";
  right = "DP-4";
in
{
  machine = {
    shell = "nushell";
    monitors = { inherit main right; };
    monitorRules = [
      {
        name = "Gaming monitors";
        outputs_connected = [
          main
          right
        ];
        configure_row = [
          main
          right
        ];
        primary = main;
        atomic = true;
        execute_after = [
          "${pkgs.xrandr}/bin/xrandr --output ${main} --mode 3840x2160 --rate 144 --dpi 192 --primary"
          "${pkgs.xrandr}/bin/xrandr --output ${right} --mode 2560x1440 --rate 100 --rotate normal"
        ];
      }
    ];
  };

  modules = {
    desktop = {
      dwm.enable = true;
      niri.enable = true;
      oxwm.enable = true;
    };
    virtualisation = {
      enable = true;
      swtpm = true;
      # GTX 1080 Ti and its HDMI audio, passed to the Windows VM
      vfio = {
        enable = true;
        ids = [
          "10de:1b06"
          "10de:10ef"
        ];
      };
    };
    yubikey = {
      enable = true;
      usbip = "server";
    };
    recording = {
      enable = true;
      nvidiaLibs = true;
    };
    fileManager.enable = true;
    performance.enable = true;
    gaming.enable = true;
    docker.enable = true;
  };

  # RTX 3080; the vfio'd 1080 Ti doesn't use this driver
  drivers.nvidia.open = true;
}
