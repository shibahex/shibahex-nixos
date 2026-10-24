{ pkgs, ... }: {
  boot.kernelModules = [ "cpufreq_stats" ];
  powerManagement.powertop.enable = false;
  environment.systemPackages = [ pkgs.powertop ];

  # Start dockerd on first use (socket activation) instead of at boot
  virtualisation.docker.enableOnBoot = false;

  services = {
    thermald.enable = false;
    power-profiles-daemon.enable = false;

    # upower for batter stats
    upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # Cap the iGPU clock on battery (i5-8350U UHD 620: 300-1100 MHz)
        INTEL_GPU_MIN_FREQ_ON_BAT = 300;
        INTEL_GPU_MAX_FREQ_ON_BAT = 700;
        INTEL_GPU_BOOST_FREQ_ON_BAT = 700;

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        # Turn Bluetooth/WWAN off on battery when nothing is connected
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wwan";
        # No bluez in this config, so the radios are never used
        DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";

        SOUND_POWER_SAVE_ON_BAT = 1;
        SOUND_POWER_SAVE_CONTROLLER = "Y";

        NMI_WATCHDOG = 0;
        MEM_SLEEP_ON_BAT = "deep";

        # Flush disk writes every 15s on battery (TLP default is 60s)
        MAX_LOST_WORK_SECS_ON_BAT = 15;

        # Dual battery support
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 90;
        START_CHARGE_THRESH_BAT1 = 60;
        STOP_CHARGE_THRESH_BAT1 = 90;
      };
    };

    # Optional: disable unless you really want it
    system76-scheduler.enable = true;
    #NOTE: GHOSTTY KILLS BATTERY LIFE
  };

  # Stop the watchdog timer
  boot.kernelParams = [ "nowatchdog" ];
}
