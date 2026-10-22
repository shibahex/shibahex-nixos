{
  lib,
  pkgs,
  username,
  ...
}:
{
  services.fstrim.enable = lib.mkDefault true; # SSD optimizer

  security.rtkit.enable = lib.mkDefault true;

  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
    wireplumber.enable = lib.mkDefault true;
    jack.enable = lib.mkDefault true;

    extraConfig.pipewire."10-clock-rate" = {
      "context.properties" = {
        # Not pinned, so PipeWire switches to a file's native rate when the device is idle
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
        ];

        # The graph runs at the smallest quantum any client asks for: desktop audio
        # idles at 1024, REAPER/JACK can pull it down to 64 for low-latency monitoring.
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 8192;
      };
    };

    # Only used when rate-matching isn't possible
    extraConfig.pipewire-pulse."10-resample-quality" = {
      "stream.properties" = {
        "resample.quality" = 10; # SoX VHQ
      };
    };

    # Universal Audio Volt 2 (USB 2.0); no effect on machines without it
    wireplumber.extraConfig."10-volt2-alsa" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "~alsa_output.usb-Universal_Audio_Volt*"; }
          ];
          actions.update-props = {
            # 256 @ 48kHz is the realistic USB 2.0 floor; raise to 512 on xruns
            "api.alsa.period-size" = 256;
            "audio.format" = "S32LE";
          };
        }
      ];
    };
  };

  boot = {
    # Threaded IRQs let rtkit prioritize the sound card's interrupts
    kernelParams = [ "threadirqs" ];
    blacklistedKernelModules = [ "pcspkr" ];
  };

  users.users.${username}.extraGroups = [
    "audio"
    "rtkit"
  ];

  environment.systemPackages = with pkgs; [
    alsa-utils
    qpwgraph
  ];
}
