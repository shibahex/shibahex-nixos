{ config, pkgs, ... }:
{
  # RTKit - grants PipeWire realtime scheduling via DBus
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;

    # --- PipeWire Core: rate + dual-mode quantum ---
    extraConfig.pipewire."10-clock-rate" = {
      "context.properties" = {
        # Base/fallback rate. Not pinned, so rate-switching stays enabled.
        "default.clock.rate" = 48000;

        # Bit-perfect hi-fi: play 44.1k / 96k / 192k files at native rate
        # instead of resampling. PipeWire switches when the device is idle.
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
        ];

        # The graph runs at the SMALLEST quantum any active client asks for.
        #   default 1024 -> music + desktop rest here (cheap).
        #   min 64       -> lets REAPER/JACK pull down to ~128 for monitoring
        #                   (128 @ 48kHz = ~5.3ms). Closing REAPER relaxes it.
        #   max 8192     -> idle-buffering headroom.
        # Quantum changes timing only, never sound quality.
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 8192;
      };
    };

    # --- Pulse resampler: only used when rate-matching isn't possible ---
    extraConfig.pipewire-pulse."10-resample-quality" = {
      "stream.properties" = {
        "resample.quality" = 10; # SoX VHQ
      };
    };

    # --- WirePlumber: Volt 2 (USB 2.0 batch device) ---
    wireplumber.extraConfig."10-volt2-alsa" = {
      "monitor.alsa.rules" = [
        {
          # Verify the exact node name: wpctl status | grep -i volt
          matches = [
            { "node.name" = "~alsa_output.usb-Universal_Audio_Volt*"; }
          ];
          actions.update-props = {
            # 256 @ 48kHz is the realistic USB 2.0 floor.
            # Crackle/xruns at low quantum -> raise to 512.
            "api.alsa.period-size" = 256;

            # 32-bit internal processing.
            "audio.format" = "S32LE";
          };
        }
      ];
    };
  };

  boot = {
    # Route IRQ handlers into kernel threads so sound-card IRQs can be
    # prioritized above other hardware.
    kernelParams = [ "threadirqs" ];

    # pcspkr fires interrupts that compete with audio.
    blacklistedKernelModules = [ "pcspkr" ];
  };

  # Prevent CPU downclocking mid-playback (a common hidden xrun cause).
  powerManagement.cpuFreqGovernor = "performance";

  users.users.shiba.extraGroups = [
    "audio"
    "rtkit"
  ];

  environment.systemPackages = with pkgs; [
    alsa-utils # amidi, aconnect, aplaymidi
    qpwgraph # visual PipeWire patchbay (audio + MIDI)
  ];
}
